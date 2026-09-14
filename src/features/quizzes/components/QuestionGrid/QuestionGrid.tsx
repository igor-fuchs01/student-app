import { QUESTION_STATUS_LABEL } from "@features/quizzes/questionReviewStatus";
import {
  StyledGrid,
  StyledTile,
  StyledLegend,
  StyledLegendItem,
  StyledLegendDot,
  type QuestionGridVariant,
  type QuestionTileTone,
} from "./QuestionGrid.styles";

export type QuestionGridTile = {
  id: string;
  tone: QuestionTileTone;
  marked?: boolean;
  current?: boolean;
};

export type QuestionGridLegendItem = {
  label: string;
  tone?: QuestionTileTone;
  marked?: boolean;
  current?: boolean;
};

type QuestionGridProps = {
  tiles: QuestionGridTile[];
  legend: QuestionGridLegendItem[];
  onSelect: (index: number) => void;
  variant?: QuestionGridVariant;
};

const TONE_LABEL: Record<QuestionTileTone, string> = {
  ...QUESTION_STATUS_LABEL,
  answered: "Respondida",
  empty: "Não respondida",
};

export function QuestionGrid({ tiles, legend, onSelect, variant = "compact" }: QuestionGridProps) {
  return (
    <>
      <StyledGrid $variant={variant}>
        {tiles.map((tile, index) => (
          <StyledTile
            key={tile.id}
            type="button"
            $variant={variant}
            $tone={tile.tone}
            $marked={Boolean(tile.marked)}
            $current={Boolean(tile.current)}
            aria-label={`Questão ${index + 1}: ${TONE_LABEL[tile.tone]}${tile.marked ? ", marcada para revisão" : ""}`}
            aria-current={tile.current ? "step" : undefined}
            onClick={() => onSelect(index)}
          >
            {index + 1}
          </StyledTile>
        ))}
      </StyledGrid>
      <StyledLegend $variant={variant}>
        {legend.map((item) => (
          <StyledLegendItem key={item.label}>
            <StyledLegendDot
              $tone={item.tone}
              $marked={Boolean(item.marked)}
              $current={Boolean(item.current)}
            />
            {item.label}
          </StyledLegendItem>
        ))}
      </StyledLegend>
    </>
  );
}
