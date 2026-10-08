import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation } from "@tanstack/react-query";
import { z } from "zod";
import { loginFormSchema, registerFormSchema } from "@models/auth";
import { TextField } from "@components/ui/TextField";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { authApi } from "@services/api/authApi";
import { TURNSTILE_SITE_KEY } from "@services/api/config";
import { TurnstileWidget } from "@features/auth/components/TurnstileWidget";
import {
  StyledPage,
  StyledFormCard,
  StyledBrand,
  StyledTitle,
  StyledSubmitButton,
  StyledModeButton,
  StyledFormError,
  StyledHint,
} from "./LoginPage.styles";

// "register" is the temporary first access: the student claims an access code handed out by the
// operator and chooses the password, then is logged in as usual.
type Mode = "login" | "register";

type FieldErrors = {
  displayName?: string;
  accessCode?: string;
  password?: string;
  passwordConfirmation?: string;
};

function errorMessage(err: unknown): string {
  return err instanceof Error ? err.message : "Não foi possível entrar. Tente novamente.";
}

export function LoginPage() {
  const navigate = useNavigate();
  const login = useAuthStore((state) => state.login);
  const status = useAuthStore((state) => state.status);
  const storedDisplayName = useAuthStore((state) => state.displayName);
  const register = useMutation({ mutationFn: authApi.register });

  const [mode, setMode] = useState<Mode>("login");
  const [displayName, setDisplayName] = useState(storedDisplayName ?? "");
  const [accessCode, setAccessCode] = useState("");
  const [password, setPassword] = useState("");
  const [passwordConfirmation, setPasswordConfirmation] = useState("");
  const [formError, setFormError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [captchaResetKey, setCaptchaResetKey] = useState(0);

  const isRegistering = mode === "register";
  const isSubmitting = status === "authenticating" || register.isPending;

  function switchMode() {
    setMode(isRegistering ? "login" : "register");
    setPassword("");
    setPasswordConfirmation("");
    setFieldErrors({});
    setFormError(null);
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError(null);

    const result = (isRegistering ? registerFormSchema : loginFormSchema).safeParse({
      displayName,
      accessCode,
      password,
      passwordConfirmation,
    });
    if (!result.success) {
      const issues: Partial<Record<keyof FieldErrors, string[]>> = z.flattenError(
        result.error,
      ).fieldErrors;
      setFieldErrors({
        displayName: issues.displayName?.[0],
        accessCode: issues.accessCode?.[0],
        password: issues.password?.[0],
        passwordConfirmation: issues.passwordConfirmation?.[0],
      });
      return;
    }
    setFieldErrors({});

    if (TURNSTILE_SITE_KEY && !captchaToken) {
      setFormError("Confirme que você não é um robô.");
      return;
    }

    const { displayName: name, accessCode: code, password: secret } = result.data;
    const credentials = { accessCode: code, password: secret };

    // Only the login checks the CAPTCHA, so a failed registration keeps the token.
    if (isRegistering) {
      try {
        await register.mutateAsync(credentials);
      } catch (err) {
        setFormError(errorMessage(err));
        return;
      }
    }

    try {
      await login(credentials, name, captchaToken ?? undefined);
      navigate("/", { replace: true });
    } catch (err) {
      // The account exists by now, so a retry is a plain login.
      setMode("login");
      setFormError(errorMessage(err));
      setCaptchaResetKey((key) => key + 1);
    }
  }

  return (
    <StyledPage>
      <StyledFormCard onSubmit={handleSubmit} noValidate>
        <StyledBrand size="lg" />
        <StyledTitle>
          {isRegistering ? "Primeiro acesso" : "Que bom ter você de volta!"}
        </StyledTitle>

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
          label={isRegistering ? "Crie uma senha" : "Senha"}
          type="password"
          placeholder={isRegistering ? "Pelo menos 6 caracteres" : "••••••••"}
          autoComplete={isRegistering ? "new-password" : "current-password"}
          value={password}
          onChange={(event) => {
            setPassword(event.target.value);
            setFieldErrors((current) => ({ ...current, password: undefined }));
          }}
          errorMessage={fieldErrors.password}
          disabled={isSubmitting}
          required
        />
        {isRegistering && (
          <TextField
            label="Confirme a senha"
            type="password"
            placeholder="Digite a senha de novo"
            autoComplete="new-password"
            value={passwordConfirmation}
            onChange={(event) => {
              setPasswordConfirmation(event.target.value);
              setFieldErrors((current) => ({ ...current, passwordConfirmation: undefined }));
            }}
            errorMessage={fieldErrors.passwordConfirmation}
            disabled={isSubmitting}
            required
          />
        )}

        {TURNSTILE_SITE_KEY && (
          <TurnstileWidget
            siteKey={TURNSTILE_SITE_KEY}
            resetKey={captchaResetKey}
            onTokenChange={setCaptchaToken}
          />
        )}

        {formError && <StyledFormError role="alert">{formError}</StyledFormError>}

        <StyledSubmitButton type="submit" isLoading={isSubmitting}>
          {isRegistering ? "Criar senha e entrar" : "Entrar"}
        </StyledSubmitButton>

        <StyledModeButton type="button" onClick={switchMode} disabled={isSubmitting}>
          {isRegistering ? "Já criou sua senha? Entre" : "Primeiro acesso? Crie sua senha"}
        </StyledModeButton>

        <StyledHint>
          Seu nome fica salvo só neste navegador e nunca é enviado ao servidor. <br />
          Acesso fornecido pelo provedor desse aplicativo. Em caso de dificuldades, contate-o.
        </StyledHint>
      </StyledFormCard>
    </StyledPage>
  );
}
