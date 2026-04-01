class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.string :name,               null: false
      t.string :email
      t.string :phone
      t.string :relationship_stage, null: false, default: "acquaintance"
      t.string :sphere_category,    null: false, default: "C"
      t.date   :last_touch_date
      t.text   :notes

      t.timestamps
    end
  end
end
