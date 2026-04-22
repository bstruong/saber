class CreateContactMethods < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_methods do |t|
      t.references :person,      null: false, foreign_key: true
      t.string     :method_type, null: false
      t.string     :value,       null: false

      t.timestamps
    end
  end
end
