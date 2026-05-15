import { Sparkles } from "lucide-react";
import { useCurrentUser } from "@/auth/hooks";
import {
  useReconnectReminders,
  useUpcomingGroups,
  usePeople,
} from "@/dashboard/hooks";
import { useDocumentTitle } from "@/lib/use-document-title";
import { getGreeting } from "@/lib/greeting";
import { StatCard } from "@/components/StatCard";
import { ReconnectCard } from "@/components/ReconnectCard";
import { EmptyState } from "@/components/EmptyState";

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

      <section className="space-y-2.5">
        <h2 className="text-label font-medium uppercase tracking-wider text-muted-foreground">
          Reconnect
        </h2>

        {reconnectQuery.isPending ? (
          <p className="text-meta text-muted-foreground">Loading...</p>
        ) : reconnectQuery.data && reconnectQuery.data.length > 0 ? (
          <div className="flex flex-col gap-2.5">
            {reconnectQuery.data.map((reminder) => (
              <ReconnectCard key={reminder.id} reminder={reminder} />
            ))}
          </div>
        ) : (
          <EmptyState
            icon={Sparkles}
            headline="You're all caught up."
            subtext="Check back tomorrow or add someone new."
          />
        )}
      </section>
    </div>
  );
}
