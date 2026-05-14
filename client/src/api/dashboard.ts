import { apiFetch } from "./client";

export type Ring = "inner_circle" | "network" | "community" | "acquaintances";

export type DashboardPerson = {
  id: number;
  name: string;
  ring: Ring;
  last_connected_at: string | null;
};

export type ReconnectReminder = {
  id: number;
  due_at: string;
  reason: string;
  snoozed_until: string | null;
  person: DashboardPerson;
};

export type UpcomingDate = {
  name: string;
  month: number;
  day: number;
  days_until: number;
};

export type UpcomingGroup = {
  person: DashboardPerson;
  upcoming_dates: UpcomingDate[];
};

export function fetchReconnectReminders(): Promise<ReconnectReminder[]> {
  return apiFetch<ReconnectReminder[]>("/api/dashboard/reconnect");
}

export function fetchUpcomingGroups(): Promise<UpcomingGroup[]> {
  return apiFetch<UpcomingGroup[]>("/api/dashboard/upcoming");
}
