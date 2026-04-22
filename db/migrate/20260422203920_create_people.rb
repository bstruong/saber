class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.string   :name,                 null: false
      t.string   :ring,                 null: false
      t.text     :notes
      t.text     :needs
      t.integer  :soi_score
      t.string   :score_source,         null: false, default: "computed"
      t.integer  :cadence_days
      t.integer  :cadence_override_days
      t.datetime :last_contacted_at
      t.string   :relationship_tags,    array: true, default: []
      t.string   :cultural_tags,        array: true, default: []

      t.timestamps
    end
  end
end
