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

ActiveRecord::Schema[7.2].define(version: 2025_08_17_113100) do
  create_table "employees", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["slug"], name: "index_employees_on_slug", unique: true
  end

  create_table "secret_santa_assignments", force: :cascade do |t|
    t.integer "employee_id", null: false
    t.integer "secret_child_id", null: false
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_secret_santa_assignments_on_employee_id"
    t.index ["secret_child_id"], name: "index_secret_santa_assignments_on_secret_child_id"
  end

  add_foreign_key "secret_santa_assignments", "employees"
  add_foreign_key "secret_santa_assignments", "employees", column: "secret_child_id"
end
