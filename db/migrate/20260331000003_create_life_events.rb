class CreateLifeEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :life_events do |t|
      t.references :contact,    null: false, foreign_key: true
      t.string     :event_type, null: false
      t.date       :event_date, null: false
      t.text       :notes

      t.timestamps
    end

    add_index :life_events, [:contact_id, :event_date]
  end
end
