import { useEffect, useRef, useState } from "react";
import { Outlet, useBlocker, useLocation, useNavigate, useParams } from "react-router-dom";
import { useMutation, useQuery } from "@tanstack/react-query";
import { StatusMessage } from "@components/ui/StatusMessage";
import { PageLayout } from "@components/layout/PageLayout";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { StartQuizModal } from "@features/quizzes/components/StartQuizModal";
import type { QuizAttemptContextValue } from "@features/quizzes/hooks/useQuizAttemptContext";
import { toggleSetItem } from "@features/quizzes/toggleSetItem";
import { quizzesApi } from "@services/api/quizzesApi";
import { quizAttemptStorage } from "@services/storage/quizAttemptStorage";
import type { QuizAnswer } from "@models/quizzes";

const LEAVE_ATTEMPT_MESSAGE =
  "Você está no meio de um simulado. Se sair agora, as informações desta atividade serão perdidas. Deseja sair mesmo assim?";

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
  const userId = useAuthStore((state) => state.user?.id);

  const quizQuery = useQuery({
    queryKey: ["quiz", quizId],
    queryFn: ({ signal }) => quizzesApi.getQuiz(quizId, signal),
  });
  const quiz = quizQuery.data;

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
  const [startedAt, setStartedAt] = useState<number | null>(null);
  const [now, setNow] = useState(() => Date.now());
  const autoSubmittedRef = useRef(false);

  const inProgress = hasStarted && !isFinished && Boolean(quiz);
  const attemptBasePath = `/simulados/${quizId}`;

  const elapsedSeconds = startedAt === null ? 0 : Math.max(0, Math.floor((now - startedAt) / 1000));
  const remainingSeconds = Math.max(0, (quiz?.durationMinutes ?? 0) * 60 - elapsedSeconds);
  const isTimeUp = timeLimitEnabled && startedAt !== null && remainingSeconds === 0;

  const blocker = useBlocker(
    ({ nextLocation }) =>
      inProgress &&
      nextLocation.pathname !== "/login" &&
      nextLocation.pathname !== attemptBasePath &&
      !nextLocation.pathname.startsWith(`${attemptBasePath}/`),
  );

  useEffect(() => {
    if (blocker.state !== "blocked") return;

    if (window.confirm(LEAVE_ATTEMPT_MESSAGE)) {
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
    if (hasStarted && quiz && startedAt === null) {
      setStartedAt(Date.now());
    }
  }, [hasStarted, quiz, startedAt]);

  useEffect(() => {
    if (startedAt === null || isFinished) return;

    const interval = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(interval);
  }, [startedAt, isFinished]);

  const {
    mutate: submitAttempt,
    isPending: isSubmitting,
    error: submitError,
  } = useMutation({
    mutationFn: () => quizzesApi.submitQuizAttempt(quizId, Object.values(answers)),
    onSuccess: (result) => {
      if (quiz && userId) {
        quizAttemptStorage.save(userId, { quiz, answers: Object.values(answers), result });
      }
      setIsFinished(true);
      navigate(`${attemptBasePath}/resultado`);
    },
  });

  useEffect(() => {
    if (!isTimeUp || isFinished || autoSubmittedRef.current) return;

    autoSubmittedRef.current = true;
    submitAttempt();
  }, [isTimeUp, isFinished, submitAttempt]);

  function setAnswer(questionId: string, patch: Omit<QuizAnswer, "questionId">) {
    if (isTimeUp) return;
    setAnswers((current) => ({ ...current, [questionId]: { questionId, ...patch } }));
  }

  function toggleMarkedForReview(questionId: string) {
    setMarkedForReview((current) => toggleSetItem(current, questionId));
  }

  function startAttempt(chosenTimeLimitEnabled: boolean) {
    setTimeLimitEnabled(chosenTimeLimitEnabled);
    setHasStarted(true);
  }

  const contextValue: QuizAttemptContextValue | null = quiz
    ? {
        quiz,
        currentIndex,
        setCurrentIndex,
        answers,
        setAnswer,
        markedForReview,
        toggleMarkedForReview,
        timeLimitEnabled,
        remainingSeconds,
        elapsedSeconds,
        isTimeUp,
        showTimer,
        toggleShowTimer: () => setShowTimer((current) => !current),
        isSubmitting,
        submitError: submitError?.message ?? null,
        submit: () => submitAttempt(),
      }
    : null;

  return (
    <PageLayout
      active="simulados"
      logoutConfirmation={inProgress ? LEAVE_ATTEMPT_MESSAGE : undefined}
    >
      {(quizQuery.isLoading || !contextValue) && !quizQuery.isError && (
        <StatusMessage message="Carregando simulado…" />
      )}

      {quizQuery.isError && (
        <StatusMessage
          message="Não foi possível carregar este simulado."
          error={quizQuery.error}
          action={{ label: "Voltar para simulados", onClick: () => navigate("/simulados") }}
        />
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
    </PageLayout>
  );
}
