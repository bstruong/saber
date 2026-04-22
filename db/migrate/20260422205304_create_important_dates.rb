class CreateImportantDates < ActiveRecord::Migration[8.1]
  def change
    create_table :important_dates do |t|
      t.references :person, null: false, foreign_key: true
      t.string     :name,   null: false
      t.integer    :month,  null: false
      t.integer    :day,    null: false

      t.timestamps
    end
  end
end
