class RenamePersonRelationshipVocabulary < ActiveRecord::Migration[8.1]
  def change
    rename_column :people, :soi_score,                 :connection_score
    rename_column :people, :value_exchange_score,      :reciprocity_score
    rename_column :people, :objective_alignment_score, :shared_values_score
    rename_column :people, :last_contacted_at,         :last_connected_at

    reversible do |dir|
      dir.up do
        execute "UPDATE people SET ring = 'inner_circle'  WHERE ring = 'board_of_advisors'"
        execute "UPDATE people SET ring = 'acquaintances' WHERE ring = 'audience'"
      end
      dir.down do
        execute "UPDATE people SET ring = 'board_of_advisors' WHERE ring = 'inner_circle'"
        execute "UPDATE people SET ring = 'audience'          WHERE ring = 'acquaintances'"
      end
    end
  end
end
