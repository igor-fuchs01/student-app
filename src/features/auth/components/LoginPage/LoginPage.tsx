import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { z } from "zod";
import { loginCredentialsSchema } from "@models/auth";
import { TextField } from "@components/ui/TextField";
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

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [formError, setFormError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<{ email?: string; password?: string }>({});

  const isSubmitting = status === "authenticating";

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setFormError(null);

    const result = loginCredentialsSchema.safeParse({ email, password });
    if (!result.success) {
      const issues = z.flattenError(result.error).fieldErrors;
      setFieldErrors({
        email: issues.email?.[0],
        password: issues.password?.[0],
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
    }
  }

  return (
    <StyledPage>
      <StyledFormCard onSubmit={handleSubmit} noValidate>
        <StyledBrand>🎓 Student App</StyledBrand>
        <StyledTitle>Que bom ter você de volta!</StyledTitle>

        <TextField
          label="E-mail"
          type="email"
          placeholder="E-mail institucional"
          autoComplete="email"
          value={email}
          onChange={(event) => {
            setEmail(event.target.value);
            setFieldErrors((current) => ({ ...current, email: undefined }));
          }}
          errorMessage={fieldErrors.email}
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
