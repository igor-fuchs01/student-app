import { useEffect, useRef, useState } from "react";
import { StyledLoadError, StyledWidget } from "./TurnstileWidget.styles";

const SCRIPT_URL = "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit";

type TurnstileRenderOptions = {
  sitekey: string;
  language: string;
  callback: (token: string) => void;
  "expired-callback": () => void;
  "error-callback": () => void;
};

type Turnstile = {
  render: (container: HTMLElement, options: TurnstileRenderOptions) => string;
  reset: (widgetId: string) => void;
  remove: (widgetId: string) => void;
};

declare global {
  interface Window {
    turnstile?: Turnstile;
  }
}

let turnstileLoader: Promise<Turnstile> | null = null;

function loadTurnstile(): Promise<Turnstile> {
  turnstileLoader ??= new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = SCRIPT_URL;
    script.async = true;
    script.onload = () =>
      window.turnstile ? resolve(window.turnstile) : reject(new Error("Turnstile missing"));
    script.onerror = () => {
      script.remove();
      turnstileLoader = null;
      reject(new Error("Turnstile script failed to load"));
    };
    document.head.appendChild(script);
  });
  return turnstileLoader;
}

type TurnstileWidgetProps = {
  siteKey: string;
  resetKey: number;
  onTokenChange: (token: string | null) => void;
};

export function TurnstileWidget({ siteKey, resetKey, onTokenChange }: TurnstileWidgetProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const widgetRef = useRef<{ turnstile: Turnstile; id: string } | null>(null);
  const onTokenChangeRef = useRef(onTokenChange);
  const [loadFailed, setLoadFailed] = useState(false);

  useEffect(() => {
    onTokenChangeRef.current = onTokenChange;
  });

  useEffect(() => {
    let cancelled = false;

    loadTurnstile()
      .then((turnstile) => {
        if (cancelled || !containerRef.current) return;
        const id = turnstile.render(containerRef.current, {
          sitekey: siteKey,
          language: "pt-br",
          callback: (token) => onTokenChangeRef.current(token),
          "expired-callback": () => onTokenChangeRef.current(null),
          "error-callback": () => onTokenChangeRef.current(null),
        });
        widgetRef.current = { turnstile, id };
      })
      .catch(() => {
        if (!cancelled) setLoadFailed(true);
      });

    return () => {
      cancelled = true;
      widgetRef.current?.turnstile.remove(widgetRef.current.id);
      widgetRef.current = null;
    };
  }, [siteKey]);

  useEffect(() => {
    if (resetKey === 0 || !widgetRef.current) return;
    widgetRef.current.turnstile.reset(widgetRef.current.id);
    onTokenChangeRef.current(null);
  }, [resetKey]);

  return (
    <StyledWidget ref={containerRef}>
      {loadFailed && (
        <StyledLoadError role="alert">
          Não foi possível carregar a verificação de segurança. Recarregue a página.
        </StyledLoadError>
      )}
    </StyledWidget>
  );
}
