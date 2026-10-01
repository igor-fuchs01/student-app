import { StyledTableWrapper, StyledTable, StyledHeaderCell, StyledCell } from "./ChartTable.styles";

export type ChartTableColumn = { label: string; numeric?: boolean };

type ChartTableProps = {
  columns: ChartTableColumn[];
  rows: { key: string; cells: (string | number)[] }[];
};

export function ChartTable({ columns, rows }: ChartTableProps) {
  return (
    <StyledTableWrapper>
      <StyledTable>
        <thead>
          <tr>
            {columns.map((column) => (
              <StyledHeaderCell key={column.label} scope="col" $numeric={Boolean(column.numeric)}>
                {column.label}
              </StyledHeaderCell>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.key}>
              {row.cells.map((cell, index) => (
                <StyledCell key={columns[index].label} $numeric={Boolean(columns[index].numeric)}>
                  {cell}
                </StyledCell>
              ))}
            </tr>
          ))}
        </tbody>
      </StyledTable>
    </StyledTableWrapper>
  );
}
