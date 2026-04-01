class CreateTouchCadences < ActiveRecord::Migration[8.1]
  def change
    create_table :touch_cadences do |t|
      t.references :contact,      null: false, foreign_key: true, index: { unique: true }
      t.string     :cadence_type, null: false
      t.datetime   :last_completed_at
      t.datetime   :next_due_at
      t.string     :status,       null: false, default: "on_track"

      t.timestamps
    end

    add_index :touch_cadences, [:status, :next_due_at]
  end
end
