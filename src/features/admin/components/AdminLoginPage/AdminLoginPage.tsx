import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { z } from "zod";
import { loginCredentialsSchema } from "@models/auth";
import { TextField } from "@components/ui/TextField";
import { TurnstileWidget } from "@features/auth/components/TurnstileWidget";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { adminApi } from "@services/api/adminApi";
import { TURNSTILE_SITE_KEY, USE_MOCKS } from "@services/api/config";
import {
  StyledPage,
  StyledFormCard,
  StyledBrand,
  StyledTitle,
  StyledSubmitButton,
  StyledFormError,
  StyledHint,
} from "./AdminLoginPage.styles";

type FieldErrors = { accessCode?: string; password?: string };

export function AdminLoginPage() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const studentStatus = useAuthStore((state) => state.status);
  const logoutStudent = useAuthStore((state) => state.logout);

  const [accessCode, setAccessCode] = useState("");
  const [password, setPassword] = useState("");
  const [fieldErrors, setFieldErrors] = useState<FieldErrors>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const [captchaResetKey, setCaptchaResetKey] = useState(0);

  const login = useMutation({
    // The browser holds a single Supabase session, so a student signed in here is signed out
    // before the admin signs in.
    mutationFn: async (credentials: z.infer<typeof loginCredentialsSchema>) => {
      if (studentStatus === "authenticated") await logoutStudent();
      return adminApi.login(credentials, captchaToken ?? undefined);
    },
    onSuccess: (admin) => {
      queryClient.setQueryData(["admin", "session"], admin);
      navigate("/admin", { replace: true });
    },
    onError: (error) => {
      setFormError(error.message);
      setCaptchaResetKey((key) => key + 1);
    },
  });

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError(null);

    const credentials = loginCredentialsSchema.safeParse({ accessCode, password });
    if (!credentials.success) {
      const issues: Partial<Record<keyof FieldErrors, string[]>> = z.flattenError(
        credentials.error,
      ).fieldErrors;
      setFieldErrors({ accessCode: issues.accessCode?.[0], password: issues.password?.[0] });
      return;
    }
    setFieldErrors({});

    if (TURNSTILE_SITE_KEY && !captchaToken) {
      setFormError("Confirme que você não é um robô.");
      return;
    }

    login.mutate(credentials.data);
  }

  return (
    <StyledPage>
      <StyledFormCard onSubmit={handleSubmit} noValidate>
        <StyledBrand size="lg" />
        <StyledTitle>Administração</StyledTitle>

        <TextField
          label="Código de acesso"
          autoComplete="username"
          autoCapitalize="none"
          spellCheck={false}
          value={accessCode}
          onChange={(event) => {
            setAccessCode(event.target.value);
            setFieldErrors((current) => ({ ...current, accessCode: undefined }));
          }}
          errorMessage={fieldErrors.accessCode}
          disabled={login.isPending || USE_MOCKS}
          required
        />
        <TextField
          label="Senha"
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(event) => {
            setPassword(event.target.value);
            setFieldErrors((current) => ({ ...current, password: undefined }));
          }}
          errorMessage={fieldErrors.password}
          disabled={login.isPending || USE_MOCKS}
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

        <StyledSubmitButton type="submit" isLoading={login.isPending} disabled={USE_MOCKS}>
          Entrar
        </StyledSubmitButton>

        <StyledHint>
          {USE_MOCKS
            ? "A área de administração não está disponível no modo de demonstração."
            : "Acesso restrito. As contas de administração são criadas pelo responsável pelo sistema."}
        </StyledHint>
      </StyledFormCard>
    </StyledPage>
  );
}
