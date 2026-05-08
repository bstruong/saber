import { useParams } from "react-router";

export default function PersonPage() {
  const { id } = useParams();
  return (
    <div className="space-y-2">
      <h1 className="text-2xl font-semibold tracking-tight">Person #{id}</h1>
      <p className="text-sm text-muted-foreground">
        Contact detail lands here in M8.
      </p>
    </div>
  );
}
