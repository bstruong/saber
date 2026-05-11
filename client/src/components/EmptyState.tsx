import { type LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

export function EmptyState({
  icon: Icon,
  headline,
  subtext,
  cta,
  className,
}: {
  icon: LucideIcon;
  headline: string;
  subtext?: string;
  cta?: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center gap-3 py-12 text-center",
        className,
      )}
    >
      <Icon className="h-8 w-8 text-muted-foreground" aria-hidden />
      <p className="text-title font-medium">{headline}</p>
      {subtext && (
        <p className="text-meta text-muted-foreground">{subtext}</p>
      )}
      {cta && <div className="mt-2">{cta}</div>}
    </div>
  );
}
