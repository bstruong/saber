class AddSoiDimensionsToPersons < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :importance_score,          :integer
    add_column :people, :value_exchange_score,      :integer
    add_column :people, :objective_alignment_score, :integer
  end
end
