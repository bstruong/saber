import { Avatar } from "./Avatar";
import { RingBadge } from "./RingBadge";
import { relativeDays } from "@/lib/time";
import type { ReconnectReminder } from "@/api/dashboard";

export function ReconnectCard({ reminder }: { reminder: ReconnectReminder }) {
  const { person } = reminder;
  const lastConnected = person.last_connected_at
    ? relativeDays(person.last_connected_at)
    : "Not yet connected";

  return (
    <article className="rounded-lg border bg-card">
      <div className="grid grid-cols-[auto_1fr] gap-3 px-3.5 py-3">
        <Avatar name={person.name} />
        <div className="min-w-0">
          <div className="flex items-start justify-between gap-2">
            <div className="min-w-0">
              <p className="truncate text-name font-medium">{person.name}</p>
              <p className="mt-0.5 text-label text-muted-foreground">
                {lastConnected}
              </p>
            </div>
            <div className="flex shrink-0 items-conter gap-1.5">
              <RingBadge ring={person.ring} />
            </div>
          </div>
        </div>
      </div>
    </article>
  );
}
