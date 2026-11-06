class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :company
      t.string :profile_url
      t.string :source, null: false
      t.string :soi_ring, null: false, default: "strangers"
      t.integer :goal_importance, null: false, default: 1
      t.integer :ring_level, null: false, default: 1
      t.integer :value_exchange, null: false, default: 1
      t.integer :past_interaction_freq, null: false, default: 1
      t.integer :objective_alignment, null: false, default: 1
      t.integer :total_score
      t.string :follow_up_frequency
      t.datetime :last_contacted_at
      t.datetime :next_follow_up_due
      t.text :notes

      t.timestamps
    end

    add_index :contacts, :source
    add_index :contacts, :soi_ring
    add_index :contacts, :follow_up_frequency
    add_index :contacts, :next_follow_up_due
    add_index :contacts, :last_contacted_at
  end
end
