import { addDays, format } from "date-fns";
import { Button } from "./ui/button";
import { useSnoozeReminder } from "@/dashboard/hooks";
import type { Ring } from "@/api/dashboard";

// Smart snooze default per ring - client-side product call; no backend endpoint supplies it.
const SNOOZE_DAYS_BY_RING: Record<Ring, number> = {
  inner_circle: 3,
  network: 7,
  community: 14,
  acquaintances: 30,
};

export function SnoozeOptions({ reminderId, ring }: { reminderId: number; ring: Ring }) {
  const snooze = useSnoozeReminder();
  const recommendedDays = SNOOZE_DAYS_BY_RING[ring];

  const options = [
    { label: `${recommendedDays} days - recommended`, days: recommendedDays, recommended: true },
    { label: "3 days", days: 3, recommended: false },
    { label: "1 week", days: 7, recommended: false },
    { label: "2 weeks", days: 14, recommended: false },
    { label: "1 month", days: 30, recommended: false },
  ];

  function handleSnooze(days: number) {
    snooze.mutate({
      reminderId,
      snoozedUntil: format(addDays(new Date(), days), "yyyy-MM-dd"),
    });
  }

  return (
    <div className="flex flex-wrap gap-1.5">
      {options.map((option) => (
        <Button
          key={option.label}
          size="xs"
          variant={option.recommended ? "secondary" : "outline"}
          disabled={snooze.isPending}
          onClick={() => handleSnooze(option.days)}
        >
          {option.label}
        </Button>
      ))}
    </div>
  );
}
