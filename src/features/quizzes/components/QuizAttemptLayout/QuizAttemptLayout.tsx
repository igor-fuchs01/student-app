import { useEffect, useRef, useState } from "react";
import { Outlet, useBlocker, useLocation, useNavigate, useParams } from "react-router-dom";
import { useMutation, useQuery } from "@tanstack/react-query";
import { Button } from "@components/ui/Button";
import { AppHeader } from "@components/layout/AppHeader";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import { quizzesApi } from "@services/api/quizzesApi";
import { toggleSetItem } from "@features/quizzes/toggleSetItem";
import { quizAttemptStorage } from "@services/storage/quizAttemptStorage";
import { useLogout } from "@features/auth/hooks/useLogout";
import type { QuizAnswer } from "@models/quizzes";
import { StyledPage, StyledContent, StyledStateMessage } from "./QuizAttemptLayout.styles";
import type { QuizAttemptContextValue } from "@features/quizzes/hooks/useQuizAttemptContext";

type StartNavigationState = { timeLimitEnabled?: boolean } | null | undefined;

function readTimeLimitChoice(state: unknown): boolean | undefined {
  const navState = state as StartNavigationState;
  return typeof navState?.timeLimitEnabled === "boolean" ? navState.timeLimitEnabled : undefined;
}

export function QuizAttemptLayout() {
  const { quizId = "" } = useParams<{ quizId: string }>();
  return <QuizAttempt key={quizId} quizId={quizId} />;
}

function QuizAttempt({ quizId }: { quizId: string }) {
  const navigate = useNavigate();
  const location = useLocation();
  const logout = useLogout();

  const quizQuery = useQuery({
    queryKey: ["quiz", quizId],
    queryFn: ({ signal }) => quizzesApi.getQuiz(quizId, signal),
  });

  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState<Record<string, QuizAnswer>>({});
  const [markedForReview, setMarkedForReview] = useState<Set<string>>(new Set());
  const [isFinished, setIsFinished] = useState(false);

  const [hasStarted, setHasStarted] = useState(
    () => readTimeLimitChoice(location.state) !== undefined,
  );
  const [timeLimitEnabled, setTimeLimitEnabled] = useState(
    () => readTimeLimitChoice(location.state) ?? true,
  );
  const [showTimer, setShowTimer] = useState(true);
  const [remainingSeconds, setRemainingSeconds] = useState<number | null>(null);
  const [elapsedSeconds, setElapsedSeconds] = useState(0);
  const autoSubmittedRef = useRef(false);

  const inProgress = hasStarted && !isFinished && Boolean(quizQuery.data);
  const attemptBasePath = `/simulados/${quizId}`;

  const blocker = useBlocker(
    ({ nextLocation }) =>
      inProgress &&
      nextLocation.pathname !== "/login" &&
      nextLocation.pathname !== attemptBasePath &&
      !nextLocation.pathname.startsWith(`${attemptBasePath}/`),
  );

  useEffect(() => {
    if (blocker.state !== "blocked") return;

    const confirmed = window.confirm(
      "Você está no meio de um simulado. Se sair agora, as informações desta atividade serão perdidas. Deseja sair mesmo assim?",
    );
    if (confirmed) {
      blocker.proceed();
    } else {
      blocker.reset();
    }
  }, [blocker]);

  useEffect(() => {
    if (!inProgress) return;

    function warnBeforeUnload(event: BeforeUnloadEvent) {
      event.preventDefault();
      event.returnValue = "";
    }

    window.addEventListener("beforeunload", warnBeforeUnload);
    return () => window.removeEventListener("beforeunload", warnBeforeUnload);
  }, [inProgress]);

  useEffect(() => {
    if (quizQuery.data) {
      const totalSeconds = quizQuery.data.durationMinutes * 60;
      setRemainingSeconds((current) => current ?? totalSeconds);
    }
  }, [quizQuery.data]);

  useEffect(() => {
    if (!hasStarted || isFinished) return;

    const interval = setInterval(() => {
      if (timeLimitEnabled) {
        setRemainingSeconds((current) => (current === null ? current : Math.max(0, current - 1)));
      } else {
        setElapsedSeconds((current) => current + 1);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [hasStarted, isFinished, timeLimitEnabled]);

  useEffect(() => {
    if (
      hasStarted &&
      timeLimitEnabled &&
      !isFinished &&
      remainingSeconds === 0 &&
      !autoSubmittedRef.current
    ) {
      autoSubmittedRef.current = true;
      navigate(`${attemptBasePath}/revisao`);
    }
  }, [hasStarted, timeLimitEnabled, isFinished, remainingSeconds, navigate, attemptBasePath]);

  const submitMutation = useMutation({
    mutationFn: () => quizzesApi.submitQuizAttempt(quizId, Object.values(answers)),
    onSuccess: (result) => {
      if (quizQuery.data) {
        quizAttemptStorage.save({ quiz: quizQuery.data, answers: Object.values(answers), result });
      }
      setIsFinished(true);
      navigate(`${attemptBasePath}/resultado`);
    },
  });

  function setAnswer(questionId: string, patch: Omit<QuizAnswer, "questionId">) {
    setAnswers((current) => ({ ...current, [questionId]: { questionId, ...patch } }));
  }

  function toggleMarkedForReview(questionId: string) {
    setMarkedForReview((current) => toggleSetItem(current, questionId));
  }

  function startAttempt(chosenTimeLimitEnabled: boolean) {
    setTimeLimitEnabled(chosenTimeLimitEnabled);
    setHasStarted(true);
  }

  const contextValue: QuizAttemptContextValue | null = quizQuery.data
    ? {
        quiz: quizQuery.data,
        currentIndex,
        setCurrentIndex,
        answers,
        setAnswer,
        markedForReview,
        toggleMarkedForReview,
        timeLimitEnabled,
        remainingSeconds: remainingSeconds ?? 0,
        elapsedSeconds,
        showTimer,
        toggleShowTimer: () => setShowTimer((current) => !current),
        isSubmitting: submitMutation.isPending,
        submitError: submitMutation.isError
          ? submitMutation.error instanceof Error
            ? submitMutation.error.message
            : "Não foi possível enviar o simulado."
          : null,
        submit: () => submitMutation.mutate(),
      }
    : null;

  return (
    <StyledPage>
      <AppHeader active="simulados" onLogout={logout} />

      {(quizQuery.isLoading || !contextValue) && !quizQuery.isError && (
        <StyledContent>
          <StyledStateMessage>Carregando simulado…</StyledStateMessage>
        </StyledContent>
      )}

      {quizQuery.isError && (
        <StyledContent>
          <StyledStateMessage>
            <p role="alert">
              Não foi possível carregar este simulado.{" "}
              {quizQuery.error instanceof Error ? quizQuery.error.message : ""}
            </p>
            <Button variant="secondary" onClick={() => navigate("/simulados")}>
              Voltar para simulados
            </Button>
          </StyledStateMessage>
        </StyledContent>
      )}

      {contextValue && !hasStarted && (
        <StartQuizModal
          quizTitle={contextValue.quiz.title}
          questionCount={contextValue.quiz.questions.length}
          durationMinutes={contextValue.quiz.durationMinutes}
          onCancel={() => navigate("/simulados")}
          onConfirm={startAttempt}
        />
      )}

      {contextValue && hasStarted && <Outlet context={contextValue} />}
    </StyledPage>
  );
}
