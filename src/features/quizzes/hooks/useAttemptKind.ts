import { useMatches } from "react-router-dom";
import type { ActiveNavKey } from "@components/layout/AppHeader";

export type AttemptKind = "exam" | "exercise";

// Set as the route `handle` of the exercise routes; routes without it are simulados.
export type AttemptKindHandle = { attemptKind: AttemptKind };

type AttemptKindConfig = {
  listPath: string;
  navKey: ActiveNavKey;
  leaveMessage: string;
  loadingMessage: string;
  loadErrorMessage: string;
  backToListLabel: string;
  submitLabel: string;
  confirmSubmitTitle: string;
  resultNotFoundMessage: string;
  seeListLabel: string;
  reviewLabel: string;
};

const ATTEMPT_KINDS: Record<AttemptKind, AttemptKindConfig> = {
  exam: {
    listPath: "/simulados",
    navKey: "simulados",
    leaveMessage:
      "Você está no meio de um simulado. Se sair agora, as informações desta atividade serão perdidas. Deseja sair mesmo assim?",
    loadingMessage: "Carregando simulado…",
    loadErrorMessage: "Não foi possível carregar este simulado.",
    backToListLabel: "Voltar para simulados",
    submitLabel: "Enviar simulado",
    confirmSubmitTitle: "Enviar simulado?",
    resultNotFoundMessage: "Nenhum resultado deste simulado foi encontrado neste navegador.",
    seeListLabel: "Ver simulados",
    reviewLabel: "Rever prova",
  },
  exercise: {
    listPath: "/exercicios",
    navKey: "exercicios",
    leaveMessage:
      "Você está no meio de uma lista de exercícios. Se sair agora, as informações desta atividade serão perdidas. Deseja sair mesmo assim?",
    loadingMessage: "Carregando exercícios…",
    loadErrorMessage: "Não foi possível carregar esta lista de exercícios.",
    backToListLabel: "Voltar para exercícios",
    submitLabel: "Enviar exercícios",
    confirmSubmitTitle: "Enviar exercícios?",
    resultNotFoundMessage:
      "Nenhum resultado desta lista de exercícios foi encontrado neste navegador.",
    seeListLabel: "Ver exercícios",
    reviewLabel: "Rever exercícios",
  },
};

function isAttemptKindHandle(handle: unknown): handle is AttemptKindHandle {
  return typeof handle === "object" && handle !== null && "attemptKind" in handle;
}

export function useAttemptKind(): AttemptKindConfig & { kind: AttemptKind } {
  const handle = useMatches()
    .map((match) => match.handle)
    .find(isAttemptKindHandle);
  const kind = handle?.attemptKind ?? "exam";
  return { kind, ...ATTEMPT_KINDS[kind] };
}
