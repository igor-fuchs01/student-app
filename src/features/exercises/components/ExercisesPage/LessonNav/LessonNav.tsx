import { useId, useState } from "react";
import { formatCount } from "@utils/formatCount";
import {
  countDone,
  lessonStatus,
  subjectProgress,
  type LessonGroup,
  type LessonStatus,
  type SubjectGroup,
} from "@features/exercises/groupExercises";
import {
  StyledNav,
  StyledSubjectMeta,
  StyledSearch,
  StyledVisuallyHidden,
  StyledSegmented,
  StyledSegment,
  StyledLessonList,
  StyledLessonButton,
  StyledStatusIcon,
  StyledLessonName,
  StyledLessonCount,
  StyledEmpty,
} from "./LessonNav.styles";
import { SubjectPicker } from "./SubjectPicker";

type StatusFilter = "all" | "pending" | "done";

type LessonNavProps = {
  subjects: SubjectGroup[];
  subject: SubjectGroup;
  selectedLessonId: string | undefined;
  onSubjectChange: (subjectId: string) => void;
  onLessonSelect: (topicId: string) => void;
};

const STATUS_FILTERS: { value: StatusFilter; label: string }[] = [
  { value: "all", label: "Todas" },
  { value: "pending", label: "Pendentes" },
  { value: "done", label: "Feitas" },
];

const STATUS_ICON: Record<LessonStatus, { icon: string; label: string }> = {
  done: { icon: "✓", label: "Todas as listas feitas" },
  started: { icon: "◐", label: "Em andamento" },
  pending: { icon: "○", label: "Não iniciada" },
};

// Matches the lesson number ("3", "aula 3") or any part of its name, ignoring case and accents.
function matchesSearch(lesson: LessonGroup, search: string): boolean {
  const normalize = (text: string) => text.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
  const query = normalize(search.trim());
  if (!query) return true;
  return normalize(`aula ${lesson.topicNumber} ${lesson.topicName}`).includes(query);
}

function matchesStatus(lesson: LessonGroup, filter: StatusFilter): boolean {
  if (filter === "all") return true;
  return (lessonStatus(lesson) === "done") === (filter === "done");
}

export function LessonNav({
  subjects,
  subject,
  selectedLessonId,
  onSubjectChange,
  onLessonSelect,
}: LessonNavProps) {
  const searchId = useId();
  const { done: doneCount, total: totalCount } = subjectProgress(subject);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("all");

  const lessons = subject.lessons.filter(
    (lesson) => matchesSearch(lesson, search) && matchesStatus(lesson, statusFilter),
  );

  return (
    <StyledNav aria-label="Aulas">
      <SubjectPicker subjects={subjects} value={subject.subjectId} onChange={onSubjectChange} />
      <StyledSubjectMeta>
        {formatCount(subject.lessons.length, "aula", "aulas")} · {doneCount} de{" "}
        {formatCount(totalCount, "lista feita", "listas feitas")}
      </StyledSubjectMeta>

      <StyledVisuallyHidden htmlFor={searchId}>Buscar aula</StyledVisuallyHidden>
      <StyledSearch
        id={searchId}
        type="search"
        placeholder="Buscar aula pelo nome ou número"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
      />

      <StyledSegmented role="group" aria-label="Situação das aulas">
        {STATUS_FILTERS.map((filter) => (
          <StyledSegment
            key={filter.value}
            type="button"
            $active={statusFilter === filter.value}
            aria-pressed={statusFilter === filter.value}
            onClick={() => setStatusFilter(filter.value)}
          >
            {filter.label}
          </StyledSegment>
        ))}
      </StyledSegmented>

      {lessons.length === 0 ? (
        <StyledEmpty>Nenhuma aula encontrada.</StyledEmpty>
      ) : (
        <StyledLessonList>
          {lessons.map((lesson) => {
            const status = STATUS_ICON[lessonStatus(lesson)];
            const isSelected = lesson.topicId === selectedLessonId;
            return (
              <li key={lesson.topicId}>
                <StyledLessonButton
                  type="button"
                  $selected={isSelected}
                  aria-current={isSelected}
                  onClick={() => onLessonSelect(lesson.topicId)}
                >
                  <StyledStatusIcon
                    $status={lessonStatus(lesson)}
                    role="img"
                    aria-label={status.label}
                  >
                    {status.icon}
                  </StyledStatusIcon>
                  <StyledLessonName>
                    Aula {lesson.topicNumber} · {lesson.topicName}
                  </StyledLessonName>
                  <StyledLessonCount
                    aria-label={`${countDone(lesson)} de ${lesson.exercises.length} listas feitas`}
                  >
                    {countDone(lesson)}/{lesson.exercises.length}
                  </StyledLessonCount>
                </StyledLessonButton>
              </li>
            );
          })}
        </StyledLessonList>
      )}
    </StyledNav>
  );
}
