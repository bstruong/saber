class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.references :person,        null: false, foreign_key: true
      t.string     :reason,        null: false
      t.date       :due_at,        null: false
      t.date       :snoozed_until
      t.datetime   :dismissed_at

      t.timestamps
    end
  end
end
