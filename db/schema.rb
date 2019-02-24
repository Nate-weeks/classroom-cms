# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_02_22_145523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.string "assignment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "studentworks", force: :cascade do |t|
    t.string "work"
    t.bigint "user_id", null: false
    t.bigint "assignment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_studentworks_on_assignment_id"
    t.index ["user_id"], name: "index_studentworks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "avatar_url"
    t.string "email"
    t.string "uid"
    t.string "provider"
    t.string "oauth_token"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "studentworks", "assignments"
  add_foreign_key "studentworks", "users"
end
