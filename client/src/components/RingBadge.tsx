import { cn } from "@/lib/utils";

type Ring = "inner_circle" | "network" | "community" | "acquaintances";

const LABELS: Record<Ring, string> = {
  inner_circle: "Inner circle",
  network: "Network",
  community: "Community",
  acquaintances: "Acquaintances",
};

const VARIANTS: Record<Ring, string> = {
  inner_circle: "bg-tier-inner-bg text-tier-inner-fg",
  network: "bg-tier-network-bg text-tier-network-fg",
  community: "bg-tier-community-bg text-tier-community-fg",
  acquaintances: "bg-tier-acquaintances-bg text-tier-acquaintances-fg",
};

export function RingBadge({
  ring,
  className,
}: {
  ring: Ring;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-block whitespace-nowrap rounded-full px-2 py-0.5 text-label",
        VARIANTS[ring],
        className,
      )}
    >
      {LABELS[ring]}
    </span>
  );
}
