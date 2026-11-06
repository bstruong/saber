class CreateSundayChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :sunday_checklists, id: :uuid do |t|
      t.date :week_of, null: false
      t.boolean :answered_no_reply_emails, null: false, default: false
      t.boolean :cleared_social_dms, null: false, default: false
      t.boolean :scheduled_ring1_coffee, null: false, default: false
      t.boolean :sent_ring2_hellos, null: false, default: false
      t.boolean :followed_up_new_contacts, null: false, default: false

      t.timestamps
    end

    add_index :sunday_checklists, :week_of, unique: true
  end
end
