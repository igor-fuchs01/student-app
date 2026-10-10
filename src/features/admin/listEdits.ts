export function replaceAt<T>(list: T[], index: number, item: T): T[] {
  return list.map((current, position) => (position === index ? item : current));
}

export function removeAt<T>(list: T[], index: number): T[] {
  return list.filter((_item, position) => position !== index);
}

// Swaps the item with its neighbour; out of the list's bounds, returns the same list.
export function moveItem<T>(list: T[], index: number, offset: -1 | 1): T[] {
  const target = index + offset;
  if (target < 0 || target >= list.length) return list;

  const moved = [...list];
  [moved[index], moved[target]] = [moved[target], moved[index]];
  return moved;
}
