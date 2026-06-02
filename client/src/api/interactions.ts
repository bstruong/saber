import { apiFetch } from "./client";

export type InteractionType =
  | "coffee" | "lunch" | "text" | "call" | "email" | "event" | "other";

export type Interaction = {
  id: number;
  interaction_type: InteractionType;
  occurred_at: string;
  notes: string | null;
};

export type NewInteraction = {
  interaction_type: InteractionType;
  occurred_at: string;
  notes?: string;
};

export function createInteraction(
  personId: number,
  interaction: NewInteraction,
): Promise<Interaction> {
  return apiFetch<Interaction>(`/api/people/${personId}/interactions`, {
    method: "POST",
    body: { interaction },
  });
}
