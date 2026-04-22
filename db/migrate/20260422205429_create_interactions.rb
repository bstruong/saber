class CreateInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :interactions do |t|
      t.references :person,           null: false, foreign_key: true
      t.string     :interaction_type, null: false
      t.date       :occurred_at,      null: false
      t.text       :notes

      t.timestamps
    end
  end
end
