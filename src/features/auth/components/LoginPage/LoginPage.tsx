import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import { loginFormSchema } from "@models/auth";
import { TextField } from "@components/ui/TextField";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { TURNSTILE_SITE_KEY } from "@services/api/config";
import { TurnstileWidget } from "@features/auth/components/TurnstileWidget";
import {
  StyledPage,
  StyledFormCard,
  StyledBrand,
  StyledTitle,
  StyledSubmitButton,
  StyledFormError,
  StyledHint,
} from "./LoginPage.styles";

type FieldErrors = { displayName?: string; accessCode?: string; password?: string };

export function LoginPage() {
  const navigate = useNavigate();
  const login = useAuthStore((state) => state.login);
  const status = useAuthStore((state) => state.status);
  const storedDisplayName = useAuthStore((state) => state.displayName);

  const [displayName, setDisplayName] = useState(storedDisplayName ?? "");
  const [accessCode, setAccessCode] = useState("");
  const [password, setPassword] = useState("");
  const [formError, setFormError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [captchaResetKey, setCaptchaResetKey] = useState(0);

  const isSubmitting = status === "authenticating";

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError(null);

    const result = loginFormSchema.safeParse({ displayName, accessCode, password });
    if (!result.success) {
      const issues = z.flattenError(result.error).fieldErrors;
      setFieldErrors({
        displayName: issues.displayName?.[0],
        accessCode: issues.accessCode?.[0],
        password: issues.password?.[0],
      });
      return;
    }
    setFieldErrors({});

    if (TURNSTILE_SITE_KEY && !captchaToken) {
      setFormError("Confirme que você não é um robô.");
      return;
    }

    try {
      const { displayName: name, ...credentials } = result.data;
      await login(credentials, name, captchaToken ?? undefined);
      navigate("/", { replace: true });
    } catch (err) {
      setFormError(
        err instanceof Error ? err.message : "Não foi possível entrar. Tente novamente.",
      );
      setCaptchaResetKey((key) => key + 1);
    }
  }

  return (
    <StyledPage>
      <StyledFormCard onSubmit={handleSubmit} noValidate>
        <StyledBrand size="lg" />
        <StyledTitle>Que bom ter você de volta!</StyledTitle>

        <TextField
          label="Como quer ser chamado?"
          placeholder="Seu nome ou apelido"
          autoComplete="nickname"
          value={displayName}
          onChange={(event) => {
            setDisplayName(event.target.value);
            setFieldErrors((current) => ({ ...current, displayName: undefined }));
          }}
          errorMessage={fieldErrors.displayName}
          disabled={isSubmitting}
          required
        />
        <TextField
          label="Código de acesso"
          placeholder="Código recebido do provedor"
          autoComplete="username"
          autoCapitalize="none"
          spellCheck={false}
          value={accessCode}
          onChange={(event) => {
            setAccessCode(event.target.value);
            setFieldErrors((current) => ({ ...current, accessCode: undefined }));
          }}
          errorMessage={fieldErrors.accessCode}
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

        {TURNSTILE_SITE_KEY && (
          <TurnstileWidget
            siteKey={TURNSTILE_SITE_KEY}
            resetKey={captchaResetKey}
            onTokenChange={setCaptchaToken}
          />
        )}

        {formError && <StyledFormError role="alert">{formError}</StyledFormError>}

        <StyledSubmitButton type="submit" isLoading={isSubmitting}>
          Entrar
        </StyledSubmitButton>

        <StyledHint>
          Seu nome fica salvo só neste navegador e nunca é enviado ao servidor. <br />
          Acesso fornecido pelo provedor desse aplicativo. Em caso de dificuldades, contate-o.
        </StyledHint>
      </StyledFormCard>
    </StyledPage>
  );
}
