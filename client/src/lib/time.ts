import { differenceInDays } from "date-fns";

export function relativeDays(from: Date | string, now: Date = new Date()): string {
  const fromDate = typeof from === "string" ? new Date(from) : from;
  const days = differenceInDays(now, fromDate);

  if (days < 14) return `${days} ${days === 1 ? "day" : "days"} ago`;
  if (days < 60) {
    const weeks = Math.floor(days / 7);
    return `${weeks} ${weeks === 1 ? "week" : "weeks"} ago`;
  }
  const months = Math.floor(days / 30);
  return `${months} ${months === 1 ? "month" : "months"} ago`;
}
