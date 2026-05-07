class AddVoidedAtToInteractions < ActiveRecord::Migration[8.1]
  def change
    add_column :interactions, :voided_at, :datetime
    add_index :interactions, :voided_at
  end
end
