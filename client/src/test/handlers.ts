import { http, HttpResponse } from "msw";
import { API_BASE_URL } from "@/lib/env";

type AuthState = { user: { id: number; email: string } | null };

export const authState: AuthState = { user: null };

export function resetAuthState() {
  authState.user = null;
}

export const handlers = [
  http.get(`${API_BASE_URL}/api/users/me`, () => {
    if (!authState.user) {
      return HttpResponse.json({ error: "Unauthorized" }, { status: 401 });
    }
    return HttpResponse.json({ user: authState.user });
  }),

  http.post(`${API_BASE_URL}/api/users/sign_in`, async ({ request }) => {
    const body = (await request.json()) as {
      user?: { email?: string; password?: string };
    };
    const email = body.user?.email;
    const password = body.user?.password;

    if (email === "brian@example.com" && password === "password123") {
      authState.user = { id: 1, email };
      return HttpResponse.json({ user: authState.user });
    }

    return HttpResponse.json(
      { error: "Invalid credentials" },
      { status: 401 },
    );
  }),

  http.delete(`${API_BASE_URL}/api/users/sign_out`, () => {
    authState.user = null;
    return new HttpResponse(null, { status: 204 });
  }),

  http.get(`${API_BASE_URL}/api/dashboard/reconnect`, () => {
    return HttpResponse.json([]);
  }),

  http.get(`${API_BASE_URL}/api/dashboard/upcoming`, () => {
    return HttpResponse.json([]);
  }),

  http.get(`${API_BASE_URL}/api/people`, () => {
    return HttpResponse.json([]);
  }),
];
