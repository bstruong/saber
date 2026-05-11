import { cn } from "@/lib/utils";

export function EventBadge({
  label,
  className,
}: {
  label: string;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-block whitespace-nowrap rounded-full bg-event-bg px-2 py-0.5 text-label text-event-fg",
        className,
      )}
    >
      {label}
    </span>
  );
}
