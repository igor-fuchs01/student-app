import { useState } from "react";
import { keepPreviousData, useQuery } from "@tanstack/react-query";
import { useAuthStore } from "@features/auth/store/useAuthStore";
import { rankingApi } from "@services/api/rankingApi";
import type { ActivityDay } from "@models/ranking";
import { formatCount } from "@utils/formatCount";
import {
  StyledCalendarCard,
  StyledHeader,
  StyledTitle,
  StyledMonthNav,
  StyledMonthLabel,
  StyledNavButton,
  StyledWeekdays,
  StyledDays,
  StyledBlankDay,
  StyledDay,
  StyledMarkers,
  StyledMarker,
  StyledSummary,
  StyledLegend,
  StyledLegendSwatch,
  StyledError,
} from "./ActivityCalendar.styles";

const WEEKDAYS = ["D", "S", "T", "Q", "Q", "S", "S"];

const pad = (value: number) => String(value).padStart(2, "0");

// Months are "YYYY-MM" and days "YYYY-MM-DD" in the student's local calendar.
function toMonth(date: Date): string {
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}`;
}

function toIsoDate(date: Date): string {
  return `${toMonth(date)}-${pad(date.getDate())}`;
}

function shiftMonth(month: string, delta: number): string {
  const [year, monthNumber] = month.split("-").map(Number);
  return toMonth(new Date(year, monthNumber - 1 + delta, 1));
}

function describeDay(day: ActivityDay | undefined): string {
  if (!day) return "sem atividade";

  const submissions = [
    day.examsCount > 0 && formatCount(day.examsCount, "simulado", "simulados"),
    day.exercisesCount > 0 &&
      formatCount(day.exercisesCount, "lista de exercícios", "listas de exercícios"),
  ].filter(Boolean);

  return submissions.length > 0 ? `dia ativo, ${submissions.join(" e ")}` : "dia ativo";
}

export function ActivityCalendar() {
  const userId = useAuthStore((state) => state.user?.id);
  const today = new Date();
  const currentMonth = toMonth(today);
  const todayIso = toIsoDate(today);
  const [month, setMonth] = useState(currentMonth);

  const calendarQuery = useQuery({
    queryKey: ["activity-calendar", userId, month],
    queryFn: ({ signal }) => rankingApi.getActivityCalendar(month, signal),
    enabled: Boolean(userId),
    placeholderData: keepPreviousData,
  });

  const [year, monthNumber] = month.split("-").map(Number);
  const firstDay = new Date(year, monthNumber - 1, 1);
  const leadingBlanks = firstDay.getDay();
  const daysInMonth = new Date(year, monthNumber, 0).getDate();
  const monthName = firstDay.toLocaleDateString("pt-BR", { month: "long" });
  const monthLabel = firstDay.toLocaleDateString("pt-BR", { month: "long", year: "numeric" });

  // While another month loads, the previous month's data stays on screen but is not mixed in.
  const days = calendarQuery.data?.month === month ? calendarQuery.data.days : [];
  const dayByDate = new Map(days.map((day) => [day.date, day]));
  const examsCount = days.reduce((total, day) => total + day.examsCount, 0);
  const exercisesCount = days.reduce((total, day) => total + day.exercisesCount, 0);

  return (
    <StyledCalendarCard tone="surface">
      <StyledHeader>
        <StyledTitle>Calendário de estudos</StyledTitle>
        <StyledMonthNav>
          <StyledNavButton
            type="button"
            onClick={() => setMonth(shiftMonth(month, -1))}
            aria-label="Mês anterior"
          >
            ‹
          </StyledNavButton>
          <StyledMonthLabel aria-live="polite">
            {monthLabel.charAt(0).toUpperCase() + monthLabel.slice(1)}
          </StyledMonthLabel>
          <StyledNavButton
            type="button"
            onClick={() => setMonth(shiftMonth(month, 1))}
            disabled={month === currentMonth}
            aria-label="Próximo mês"
          >
            ›
          </StyledNavButton>
        </StyledMonthNav>
      </StyledHeader>

      <StyledWeekdays aria-hidden="true">
        {WEEKDAYS.map((weekday, index) => (
          <span key={index}>{weekday}</span>
        ))}
      </StyledWeekdays>

      <StyledDays
        $loading={calendarQuery.isFetching}
        aria-label={`Dias de estudo em ${monthName}`}
        aria-busy={calendarQuery.isFetching}
      >
        {Array.from({ length: leadingBlanks }, (_, index) => (
          <StyledBlankDay key={`blank-${index}`} aria-hidden="true" />
        ))}
        {Array.from({ length: daysInMonth }, (_, index) => {
          const dayNumber = index + 1;
          const date = `${month}-${pad(dayNumber)}`;
          const day = dayByDate.get(date);
          const label = `${dayNumber} de ${monthName}: ${describeDay(day)}`;

          return (
            <StyledDay
              key={date}
              $active={Boolean(day)}
              $today={date === todayIso}
              $future={date > todayIso}
              aria-label={label}
              title={label}
              aria-current={date === todayIso ? "date" : undefined}
            >
              {dayNumber}
              <StyledMarkers aria-hidden="true">
                {day && day.examsCount > 0 && <StyledMarker $kind="exam" />}
                {day && day.exercisesCount > 0 && <StyledMarker $kind="exercise" />}
              </StyledMarkers>
            </StyledDay>
          );
        })}
      </StyledDays>

      {calendarQuery.isError ? (
        <StyledError role="alert">
          Não foi possível carregar o calendário. {calendarQuery.error.message}
        </StyledError>
      ) : (
        <StyledSummary>
          <strong>{formatCount(days.length, "dia ativo", "dias ativos")}</strong> em {monthName}
          {" · "}
          {formatCount(examsCount, "simulado", "simulados")} ·{" "}
          {formatCount(exercisesCount, "lista de exercícios", "listas de exercícios")}
        </StyledSummary>
      )}

      <StyledLegend aria-label="Legenda">
        <li>
          <StyledLegendSwatch aria-hidden="true" />
          Dia ativo
        </li>
        <li>
          <StyledMarker $kind="exam" aria-hidden="true" />
          Simulado
        </li>
        <li>
          <StyledMarker $kind="exercise" aria-hidden="true" />
          Exercícios
        </li>
      </StyledLegend>
    </StyledCalendarCard>
  );
}
