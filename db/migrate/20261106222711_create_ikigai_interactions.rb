class CreateIkigaiInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions, id: :uuid do |t|
      t.references :contact, null: false, foreign_key: true, type: :uuid
      t.string :interaction_type, null: false
      t.text :hook_em_notes
      t.text :help_em_notes
      t.text :ask_em_notes

      t.timestamps
    end

    add_index :interactions, :interaction_type
  end
end
