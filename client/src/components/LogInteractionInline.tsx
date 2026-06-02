import { useState } from "react";
import { Button } from "./ui/button";
import { Textarea } from "./ui/textarea";
import { useLogInteraction } from "@/dashboard/hooks";

type Props = {
  personId: number;
  reminderId: number;
  onCancel: () => void;
};

export function LogInteractionInline({ personId, reminderId, onCancel }: Props) {
  const [note, setNote] = useState("");
  const logInteraction = useLogInteraction();

  function handleSave() {
    logInteraction.mutate({
      personId,
      reminderId,
      interaction: {
        interaction_type: "other",
        occurred_at: new Date().toISOString(),
        notes: note.trim() || undefined,
      },
    });
  }

  return (
    <div className="space-y-2 border-t pt-2">
      <label htmlFor={`note-${reminderId}`} className="text-label text-muted-foreground">
        How did it go? Anything worth remembering?
      </label>
      <Textarea
        id={`note-${reminderId}`}
        value={note}
        onChange={(event) => setNote(event.target.value)}
        placeholder="e.g. Grabbed boba at Boba Guys. He just got promoted..."
        rows={3}
      />
      {logInteraction.isError && (
        <p className="text-meta text-destructive">Couldn't save. Try again.</p>
      )}
      <div className="flex gap-1.5">
      <Button size="sm" variant="secondary" disabled={logInteraction.isPending} onClick={handleSave}>
        {logInteraction.isPending ? "Saving..." : "Save"}
      </Button>
      <Button size="sm" variant="ghost" disabled={logInteraction.isPending} onClick={onCancel}>
        Cancel
      </Button>
      </div>
    </div>
  );
}
