import { describe, it, expect, beforeEach } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { http, HttpResponse } from "msw";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReconnectCard } from "@/components/ReconnectCard";
import { useReconnectReminders } from "@/dashboard/hooks";
import { server } from "./server";
import { API_BASE_URL } from "@/lib/env";
import type { ReconnectReminder } from "@/api/dashboard";

const SAMPLE: ReconnectReminder = {
  id: 42,
  due_at: "2026-05-20T00:00:00.000Z",
  reason: "It's been a while.",
  snoozed_until: null,
  person: {
    id: 7,
    name: "Ada Lovelace",
    ring: "inner_circle",
    last_connected_at: "2026-04-01T00:00:00.000Z",
  },
};

function ReconnectList() {
  const { data, isLoading } = useReconnectReminders();
  if (isLoading) return <p>loading</p>;
  if (!data?.length) return <p>none</p>;
  return (
    <ul>
      {data.map((reminder) => (
        <li key={reminder.id}>
          <ReconnectCard reminder={reminder} />
        </li>
      ))}
    </ul>
  );
}

function renderList() {
  const client = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  });
  return render(
    <QueryClientProvider client={client}>
      <ReconnectList />
    </QueryClientProvider>,
  );
}

describe("ReconnectCard actions", () => {
  beforeEach(() => {
    // Stateful reconnect list — emptying on first write mirrors the backend
    // (interaction POST dismisses the active reminder; snooze removes from /reconnect).
    let reminders: ReconnectReminder[] = [SAMPLE];
    server.use(
      http.get(`${API_BASE_URL}/api/dashboard/reconnect`, () =>
        HttpResponse.json(reminders),
      ),
      http.post(`${API_BASE_URL}/api/people/:id/interactions`, () => {
        reminders = [];
        return HttpResponse.json({
          id: 1,
          interaction_type: "other",
          occurred_at: new Date().toISOString(),
          notes: null,
        });
      }),
      http.post(`${API_BASE_URL}/api/reminders/:id/snooze`, () => {
        reminders = [];
        return HttpResponse.json({ ...SAMPLE, snoozed_until: "2026-06-04" });
      }),
    );
  });

  it("logging an interaction removes the card", async () => {
    const user = userEvent.setup();
    renderList();

    await screen.findByText(/ada lovelace/i);
    await user.click(screen.getByRole("button", { name: /we connected/i }));
    await user.type(
      screen.getByLabelText(/how did it go/i),
      "Coffee at Sightglass",
    );
    await user.click(screen.getByRole("button", { name: /^save$/i }));

    await waitFor(() => {
      expect(screen.queryByText(/ada lovelace/i)).not.toBeInTheDocument();
    });
  });

  it("snoozing removes the card", async () => {
    const user = userEvent.setup();
    renderList();

    await screen.findByText(/ada lovelace/i);
    await user.click(screen.getByRole("button", { name: /remind me later/i }));
    // inner_circle → recommended pill reads "3 days - recommended"
    await user.click(
      screen.getByRole("button", { name: /3 days - recommended/i }),
    );

    await waitFor(() => {
      expect(screen.queryByText(/ada lovelace/i)).not.toBeInTheDocument();
    });
  });

  it("preserves the typed note and surfaces an error when logging fails", async () => {
    const user = userEvent.setup();
    server.use(
      http.post(`${API_BASE_URL}/api/people/:id/interactions`, () =>
        HttpResponse.json({ error: "boom" }, { status: 500 }),
      ),
    );

    renderList();
    await screen.findByText(/ada lovelace/i);
    await user.click(screen.getByRole("button", { name: /we connected/i }));

    const textarea = screen.getByLabelText(/how did it go/i);
    await user.type(textarea, "Coffee at Sightglass");
    await user.click(screen.getByRole("button", { name: /^save$/i }));

    await waitFor(() => {
      expect(
        screen.getByText(/couldn't save\. try again/i),
      ).toBeInTheDocument();
    });
    expect(screen.getByText(/ada lovelace/i)).toBeInTheDocument();
    expect(textarea).toHaveValue("Coffee at Sightglass");
  });
});
