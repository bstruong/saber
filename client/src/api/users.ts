import { apiFetch } from "./client";

export type User = {
  id: number;
  email: string;
};

type UserEnvelope = { user: User };

export async function fetchCurrentUser(): Promise<User> {
  const { user } = await apiFetch<UserEnvelope>("/api/users/me");
  return user;
}

export async function signIn(email: string, password: string): Promise<User> {
  const { user } = await apiFetch<UserEnvelope>("/api/users/sign_in", {
    method: "POST",
    body: { user: { email, password } },
  });
  return user;
}

export async function signOut(): Promise<void> {
  await apiFetch<void>("/api/users/sign_out", { method: "DELETE" });
}
