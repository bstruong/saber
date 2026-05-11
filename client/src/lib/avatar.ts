export function colorIndex(name: string): number {
  return [...name].reduce(
    (sum, char) => sum + char.charCodeAt(0),
    0,
  ) % 5;
}

export function initials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "?";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}
