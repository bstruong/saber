import { cn } from "@/lib/utils";
import { colorIndex, initials } from "@/lib/avatar";

const VARIANTS = [
  "bg-avatar-1-bg text-avatar-1-fg",
  "bg-avatar-2-bg text-avatar-2-fg",
  "bg-avatar-3-bg text-avatar-3-fg",
  "bg-avatar-4-bg text-avatar-4-fg",
  "bg-avatar-5-bg text-avatar-5-fg",
] as const;

export function Avatar({
  name,
  size = "md",
  className,
}: {
  name: string;
  size?: "md" | "lg";
  className?: string;
}) {
  return (
    <div
      className={cn(
        "inline-flex shrink-0 items-center justify-center rounded-full font-medium",
        VARIANTS[colorIndex(name)],
        size === "lg" ? "h-12 w-12 text-name" : "h-9 w-9 text-meta",
        className,
      )}
      aria-hidden
    >
      {initials(name)}
    </div>
  );
}
