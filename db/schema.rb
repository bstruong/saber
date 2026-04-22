# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_22_220657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contact_methods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "method_type", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["person_id"], name: "index_contact_methods_on_person_id"
  end

  create_table "important_dates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day", null: false
    t.integer "month", null: false
    t.string "name", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_important_dates_on_person_id"
  end

  create_table "interactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "interaction_type", null: false
    t.text "notes"
    t.date "occurred_at", null: false
    t.bigint "person_id", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_interactions_on_person_id"
  end

  create_table "people", force: :cascade do |t|
    t.integer "cadence_days"
    t.integer "cadence_override_days"
    t.datetime "created_at", null: false
    t.string "cultural_tags", default: [], array: true
    t.datetime "deleted_at"
    t.integer "importance_score"
    t.datetime "last_contacted_at"
    t.string "name", null: false
    t.text "needs"
    t.text "notes"
    t.integer "objective_alignment_score"
    t.string "relationship_tags", default: [], array: true
    t.string "ring", null: false
    t.string "score_source", default: "computed", null: false
    t.integer "soi_score"
    t.datetime "updated_at", null: false
    t.integer "value_exchange_score"
    t.index ["deleted_at"], name: "index_people_on_deleted_at"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "dismissed_at"
    t.date "due_at", null: false
    t.bigint "person_id", null: false
    t.string "reason", null: false
    t.date "snoozed_until"
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_reminders_on_person_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "contact_methods", "people"
  add_foreign_key "important_dates", "people"
  add_foreign_key "interactions", "people"
  add_foreign_key "reminders", "people"
end
