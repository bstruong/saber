class DropLegacyCrmTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :reminders, if_exists: true
    drop_table :interactions, if_exists: true
    drop_table :important_dates, if_exists: true
    drop_table :contact_methods, if_exists: true
    drop_table :people, if_exists: true
  end
end
