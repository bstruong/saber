import { apiFetch } from "./client";
import type { Ring } from "./dashboard";

export type Person = {
  id: number;
  name: string;
  ring: Ring;
  last_connected_at: string | null;
};

export function fetchPeople(): Promise<Person[]> {
  return apiFetch<Person[]>("api/people");
}
