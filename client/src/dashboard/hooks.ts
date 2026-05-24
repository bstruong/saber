import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  fetchReconnectReminders,
  fetchUpcomingGroups,
  type ReconnectReminder
} from "@/api/dashboard";
import { fetchPeople } from "@/api/people";
import { createInteraction, type NewInteraction } from "@/api/interactions";
import { snoozeReminder } from "@/api/reminders";

const RECONNECT_KEY = ["dashboard", "reconnect"] as const;

export function useReconnectReminders() {
  return useQuery({
    queryKey: RECONNECT_KEY,
    queryFn: fetchReconnectReminders,
  });
}

export function useUpcomingGroups() {
  return useQuery({
    queryKey: ["dashboard", "upcoming"],
    queryFn: fetchUpcomingGroups,
  });
}

export function usePeople() {
  return useQuery({
    queryKey: ["people"],
    queryFn: fetchPeople,
  });
}

// Optimistically drop one reminder from the reconnect list; returns a rollback snapshot.
function useRemoveReconnectCard() {
  const queryClient = useQueryClient();

  return {
    onMutate: async (reminderId: number) => {
      await queryClient.cancelQueries({ queryKey: RECONNECT_KEY });
      const previous = queryClient.getQueryData<ReconnectReminder[]>(RECONNECT_KEY);

      queryClient.setQueryData<ReconnectReminder[]>(RECONNECT_KEY,(list) =>
        (list ?? []).filter((reminder) => reminder.id !== reminderId),
      );
      return { previous };
    },
    onError: (
      _error: unknown,
      _vars: unknown,
      context?: { previous?: ReconnectReminder[] },
    ) => {
      if (context?.previous) {
        queryClient.setQueryData(RECONNECT_KEY, context.previous);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: RECONNECT_KEY });
    },
  };
}

export function useLogInteraction() {
  const remove = useRemoveReconnectCard();
  return useMutation({
    mutationFn: (vars: {
      personId: number;
      reminderId: number;
      interaction: NewInteraction;
    }) => createInteraction(vars.personId, vars.interaction),
    onMutate: (vars) => remove.onMutate(vars.reminderId),
    onError: remove.onError,
    onSettled: remove.onSettled,
  });
}

export function useSnoozeReminder() {
  const remove = useRemoveReconnectCard();
  return useMutation({
    mutationFn: (vars: { reminderId: number;snoozedUntil: string }) =>
      snoozeReminder(vars.reminderId, vars.snoozedUntil),
    onMutate: (vars) => remove.onMutate(vars.reminderId),
    onError: remove.onError,
    onSettled: remove.onSettled,
  });
}
