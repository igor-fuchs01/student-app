import { StyledSparkline, StyledSparklinePath, StyledSparklineDot } from "./Sparkline.styles";

type SparklineProps = {
  values: (number | null)[];
};

const WIDTH = 88;
const HEIGHT = 34;
const PADDING = 4;

export function Sparkline({ values }: SparklineProps) {
  const points = values.flatMap((value, index) =>
    value === null
      ? []
      : [
          [
            PADDING + (index * (WIDTH - 2 * PADDING)) / Math.max(1, values.length - 1),
            HEIGHT - PADDING - ((HEIGHT - 2 * PADDING) * value) / 100,
          ],
        ],
  );
  if (points.length < 2) return null;

  const [lastX, lastY] = points[points.length - 1];

  return (
    <StyledSparkline width={WIDTH} height={HEIGHT} aria-hidden="true">
      <StyledSparklinePath d={points.map(([x, y], i) => `${i ? "L" : "M"}${x},${y}`).join("")} />
      <StyledSparklineDot cx={lastX} cy={lastY} r={4} />
    </StyledSparkline>
  );
}
