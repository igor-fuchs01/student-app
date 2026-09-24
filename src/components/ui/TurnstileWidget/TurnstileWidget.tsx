import { forwardRef, useEffect, useImperativeHandle, useRef, useState } from "react";
import { StyledTurnstileContainer } from "./TurnstileWidget.styles";

declare global {
  interface Window {
    turnstile?: {
      render: (container: HTMLElement, options: TurnstileRenderOptions) => string;
      reset: (widgetId?: string) => void;
      remove: (widgetId?: string) => void;
    };
  }
}

type TurnstileRenderOptions = {
  sitekey: string;
  callback: (token: string) => void;
  "error-callback"?: () => void;
  "expired-callback"?: () => void;
};

const SCRIPT_SRC = "https://challenges.cloudflare.com/turnstile/v0/api.js";

let scriptLoadPromise: Promise<void> | null = null;

function loadTurnstileScript(): Promise<void> {
  if (window.turnstile) return Promise.resolve();

  if (!scriptLoadPromise) {
    scriptLoadPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script");
      script.src = SCRIPT_SRC;
      script.async = true;
      script.defer = true;
      script.onload = () => resolve();
      script.onerror = () => reject(new Error("Failed to load Turnstile script."));
      document.head.appendChild(script);
    });
  }

  return scriptLoadPromise;
}

export type TurnstileWidgetHandle = {
  reset: () => void;
};

type TurnstileWidgetProps = {
  siteKey: string;
  onVerify: (token: string) => void;
  onExpire?: () => void;
  onError?: () => void;
};

export const TurnstileWidget = forwardRef<TurnstileWidgetHandle, TurnstileWidgetProps>(
  function TurnstileWidget({ siteKey, onVerify, onExpire, onError }, ref) {
    const containerRef = useRef<HTMLDivElement>(null);
    const widgetIdRef = useRef<string | undefined>(undefined);
    const [isReady, setIsReady] = useState(false);

    useImperativeHandle(ref, () => ({
      reset() {
        if (widgetIdRef.current) window.turnstile?.reset(widgetIdRef.current);
      },
    }));

    useEffect(() => {
      let cancelled = false;

      loadTurnstileScript()
        .then(() => {
          if (cancelled || !containerRef.current || !window.turnstile) return;

          widgetIdRef.current = window.turnstile.render(containerRef.current, {
            sitekey: siteKey,
            callback: onVerify,
            "expired-callback": onExpire,
            "error-callback": onError,
          });
          setIsReady(true);
        })
        .catch(() => {
          onError?.();
        });

      return () => {
        cancelled = true;
        if (widgetIdRef.current) window.turnstile?.remove(widgetIdRef.current);
      };
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [siteKey]);

    return <StyledTurnstileContainer ref={containerRef} aria-busy={!isReady} />;
  },
);