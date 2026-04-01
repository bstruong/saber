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

ActiveRecord::Schema[8.1].define(version: 2026_03_31_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.date "last_touch_date"
    t.string "name", null: false
    t.text "notes"
    t.string "phone"
    t.string "relationship_stage", default: "acquaintance", null: false
    t.string "sphere_category", default: "C", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interactions", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "interaction_type", null: false
    t.text "notes"
    t.datetime "occurred_at", null: false
    t.string "outcome"
    t.datetime "updated_at", null: false
    t.index ["contact_id", "occurred_at"], name: "index_interactions_on_contact_id_and_occurred_at"
    t.index ["contact_id"], name: "index_interactions_on_contact_id"
  end

  create_table "life_events", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.date "event_date", null: false
    t.string "event_type", null: false
    t.text "notes"
    t.datetime "updated_at", null: false
    t.index ["contact_id", "event_date"], name: "index_life_events_on_contact_id_and_event_date"
    t.index ["contact_id"], name: "index_life_events_on_contact_id"
  end

  create_table "touch_cadences", force: :cascade do |t|
    t.string "cadence_type", null: false
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "last_completed_at"
    t.datetime "next_due_at"
    t.string "status", default: "on_track", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_touch_cadences_on_contact_id", unique: true
    t.index ["status", "next_due_at"], name: "index_touch_cadences_on_status_and_next_due_at"
  end

  add_foreign_key "interactions", "contacts"
  add_foreign_key "life_events", "contacts"
  add_foreign_key "touch_cadences", "contacts"
end
