class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions do |t|
      t.references :contact,          null: false, foreign_key: true
      t.string     :interaction_type, null: false
      t.datetime   :occurred_at,      null: false
      t.text       :notes
      t.string     :outcome

      t.timestamps
    end

    add_index :interactions, [:contact_id, :occurred_at]
  end
end
