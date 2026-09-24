import { useRef, useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import { loginCredentialsSchema } from "@models/auth";
import { TextField } from "@components/ui/TextField";
import { TurnstileWidget, type TurnstileWidgetHandle } from "@components/ui/TurnstileWidget";
import { TURNSTILE_SITE_KEY } from "@services/api/config";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import {
  StyledPage,
  StyledFormCard,
  StyledBrand,
  StyledTitle,
  StyledSubmitButton,
  StyledFormError,
  StyledHint,
} from "./LoginPage.styles";

export function LoginPage() {
  const navigate = useNavigate();
  const login = useAuthStore((state) => state.login);
  const status = useAuthStore((state) => state.status);

  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [formError, setFormError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<{
    identifier?: string;
    password?: string;
    captchaToken?: string;
  }>({});
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const turnstileRef = useRef<TurnstileWidgetHandle>(null);

  const isSubmitting = status === "authenticating";

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError(null);

    const result = loginCredentialsSchema.safeParse({ identifier, password, captchaToken });
    if (!result.success) {
      const issues = z.flattenError(result.error).fieldErrors;
      setFieldErrors({
        identifier: issues.identifier?.[0],
        password: issues.password?.[0],
        captchaToken: issues.captchaToken?.[0],
      });
      return;
    }
    setFieldErrors({});

    try {
      await login(result.data);
      navigate("/", { replace: true });
    } catch (err) {
      setFormError(
        err instanceof Error ? err.message : "Não foi possível entrar. Tente novamente.",
      );
      turnstileRef.current?.reset();
      setCaptchaToken(null);
    }
  }

  return (
    <StyledPage>
      <StyledFormCard onSubmit={handleSubmit} noValidate>
        <StyledBrand>🎓 Student App</StyledBrand>
        <StyledTitle>Que bom ter você de volta!</StyledTitle>

        <TextField
          label="Matrícula ou e-mail"
          placeholder="Matrícula ou e-mail institucional"
          autoComplete="username"
          value={identifier}
          onChange={(event) => {
            setIdentifier(event.target.value);
            setFieldErrors((current) => ({ ...current, identifier: undefined }));
          }}
          errorMessage={fieldErrors.identifier}
          disabled={isSubmitting}
          required
        />
        <TextField
          label="Senha"
          type="password"
          placeholder="••••••••"
          autoComplete="current-password"
          value={password}
          onChange={(event) => {
            setPassword(event.target.value);
            setFieldErrors((current) => ({ ...current, password: undefined }));
          }}
          errorMessage={fieldErrors.password}
          disabled={isSubmitting}
          required
        />

              <TurnstileWidget
          ref={turnstileRef}
          siteKey={TURNSTILE_SITE_KEY}
          onVerify={(token) => {
            setCaptchaToken(token);
            setFieldErrors((current) => ({ ...current, captchaToken: undefined }));
          }}
          onExpire={() => setCaptchaToken(null)}
        />

        {fieldErrors.captchaToken && (
          <StyledFormError role="alert">{fieldErrors.captchaToken}</StyledFormError>
        )}

        {formError && <StyledFormError role="alert">{formError}</StyledFormError>}

        <StyledSubmitButton type="submit" isLoading={isSubmitting}>
          Entrar
        </StyledSubmitButton>

        <StyledHint>
          Acesso fornecido pelo provedor desse aplicativo. <br />
          Em caso de dificuldades, contate-o.
        </StyledHint>
      </StyledFormCard>
    </StyledPage>
  );
}
