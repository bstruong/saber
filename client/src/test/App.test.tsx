import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { RouterProvider, createMemoryRouter } from "react-router";
import { ProtectedRoute } from "@/auth/ProtectedRoute";
import { AppLayout } from "@/layout/AppLayout";
import LoginPage from "@/routes/login";
import DashboardPage from "@/routes/dashboard";
import { resetAuthState } from "./handlers";

function renderAt(path: string) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });

  const router = createMemoryRouter(
    [
      { path: "/login", element: <LoginPage /> },
      {
        element: <ProtectedRoute />,
        children: [
          {
            element: <AppLayout />,
            children: [{ index: true, element: <DashboardPage /> }],
          },
        ],
      },
    ],
    { initialEntries: [path] },
  );

  return render(
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>,
  );
}

describe("App auth shell", () => {
  beforeEach(() => resetAuthState());

  it("redirects unauthenticated visit to /login", async () => {
    renderAt("/");
    await waitFor(() => {
      expect(screen.getByText(/sign in to saber/i)).toBeInTheDocument();
    });
  });

  it("signs in and renders the dashboard", async () => {
    const user = userEvent.setup();
    renderAt("/");

    await waitFor(() => {
      expect(screen.getByText(/sign in to saber/i)).toBeInTheDocument();
    });

    await user.type(screen.getByLabelText(/email/i), "brian@example.com");
    await user.type(screen.getByLabelText(/password/i), "password123");
    await user.click(screen.getByRole("button", { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText(/time to reconnect/i)).toBeInTheDocument();
    });
  });

  it("rejects invalid credentials with an error message", async () => {
    const user = userEvent.setup();
    renderAt("/login");

    await waitFor(() => {
      expect(screen.getByText(/sign in to saber/i)).toBeInTheDocument();
    });

    await user.type(screen.getByLabelText(/email/i), "brian@example.com");
    await user.type(screen.getByLabelText(/password/i), "wrong");
    await user.click(screen.getByRole("button", { name: /sign in/i }));

    await waitFor(() => {
      expect(screen.getByText(/invalid email or password/i)).toBeInTheDocument();
    });
  });
});
