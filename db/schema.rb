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

ActiveRecord::Schema[8.1].define(version: 2026_11_06_222711) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "follow_up_frequency"
    t.integer "goal_importance", default: 1, null: false
    t.datetime "last_contacted_at"
    t.string "name", null: false
    t.datetime "next_follow_up_due"
    t.text "notes"
    t.integer "objective_alignment", default: 1, null: false
    t.integer "past_interaction_freq", default: 1, null: false
    t.string "phone"
    t.string "profile_url"
    t.integer "ring_level", default: 1, null: false
    t.string "soi_ring", default: "strangers", null: false
    t.string "source", null: false
    t.integer "total_score"
    t.datetime "updated_at", null: false
    t.integer "value_exchange", default: 1, null: false
    t.index ["follow_up_frequency"], name: "index_contacts_on_follow_up_frequency"
    t.index ["last_contacted_at"], name: "index_contacts_on_last_contacted_at"
    t.index ["next_follow_up_due"], name: "index_contacts_on_next_follow_up_due"
    t.index ["soi_ring"], name: "index_contacts_on_soi_ring"
    t.index ["source"], name: "index_contacts_on_source"
  end

  create_table "interactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "ask_em_notes"
    t.uuid "contact_id", null: false
    t.datetime "created_at", null: false
    t.text "help_em_notes"
    t.text "hook_em_notes"
    t.string "interaction_type", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_interactions_on_contact_id"
    t.index ["interaction_type"], name: "index_interactions_on_interaction_type"
  end

  create_table "sunday_checklists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "answered_no_reply_emails", default: false, null: false
    t.boolean "cleared_social_dms", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "followed_up_new_contacts", default: false, null: false
    t.boolean "scheduled_ring1_coffee", default: false, null: false
    t.boolean "sent_ring2_hellos", default: false, null: false
    t.datetime "updated_at", null: false
    t.date "week_of", null: false
    t.index ["week_of"], name: "index_sunday_checklists_on_week_of", unique: true
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

  add_foreign_key "interactions", "contacts"
end
