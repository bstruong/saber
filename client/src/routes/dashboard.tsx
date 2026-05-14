import { useCurrentUser } from "@/auth/hooks";
import {
  useReconnectReminders,
  useUpcomingGroups,
  usePeople,
} from "@/dashboard/hooks";
import { useDocumentTitle } from "@/lib/use-document-title";
import { getGreeting } from "@/lib/greeting";
import { StatCard } from "@/components/StatCard";

function displayNameFromEmail(email: string | undefined): string {
  if (!email) return "";
  const localPart = email.split("@")[0] ?? "";
  return localPart.charAt(0).toUpperCase() + localPart.slice(1);
}

export default function DashboardPage() {
  useDocumentTitle("Dashboard");

  const { data: user } = useCurrentUser();
  const reconnectQuery = useReconnectReminders();
  const upcomingQuery = useUpcomingGroups();
  const peopleQuery = usePeople();

  const displayName = displayNameFromEmail(user?.email);
  const greeting = getGreeting();
  const heading = displayName ? `${greeting}, ${displayName}` : greeting;

  const reconnectCount = reconnectQuery.data?.length ?? 0;
  const upcomingCount = upcomingQuery.data?.length ?? 0;
  const peopleCount = peopleQuery.data?.length ?? 0;

  return (
    <div className="space-y-6">
      <h1 className="text-stat font-medium tracking-tight">{heading}</h1>

      <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-3">
        <StatCard
          label="Time to reconnect"
          value={reconnectCount}
          tone="orange"
        />
        <StatCard label="Coming up soon" value={upcomingCount} />
        <StatCard label="In your cirle" value={peopleCount} />
      </div>
    </div>
  );
}
