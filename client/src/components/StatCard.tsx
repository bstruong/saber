import { cn } from "@/lib/utils";

const TONE_STYLES = {
  default: "text-sapphire",
  orange: "text-orange-dark",
} as const;

type Tone = keyof typeof TONE_STYLES;

export function StatCard({
  label,
  value,
  tone = "default",
  className,
}: {
  label: string;
  value: number | string;
  tone?: Tone;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "rounded-md border bg-card px-3.5 py-3",
        className,
      )}
    >
      <p className="text-meta text-muted-foreground mb-1">{label}</p>
      <p className={cn("text-stat font-medium tabular-nums", TONE_STYLES[tone])}>
        {value}
      </p>
    </div>
  );
}
