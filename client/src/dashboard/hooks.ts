import { useQuery } from "@tanstack/react-query";
import { fetchReconnectReminders, fetchUpcomingGroups } from "@/api/dashboard";
import { fetchPeople } from "@/api/people";

export function useReconnectReminders() {
  return useQuery({
    queryKey: ["dashboard", "reconnect"],
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
