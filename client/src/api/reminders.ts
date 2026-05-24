import { apiFetch } from "./client";
import type { ReconnectReminder } from "./dashboard";

export function snoozeReminder(
  reminderId: number,
  snoozedUntil: string,
): Promise<ReconnectReminder> {
  return apiFetch<ReconnectReminder>(`/api/reminders/${reminderId}/snooze`, {
    method: "POST",
    body: { snoozed_until: snoozedUntil },
  });
}
