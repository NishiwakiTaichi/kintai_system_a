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

ActiveRecord::Schema[7.1].define(version: 2026_05_23_225657) do
  create_table "attendance_change_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "supervisor_id", null: false
    t.bigint "attendance_id", null: false
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.text "reason"
    t.string "status", default: "なし"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "after_started_at"
    t.datetime "after_finished_at"
    t.index ["attendance_id"], name: "index_attendance_change_applications_on_attendance_id"
    t.index ["supervisor_id"], name: "index_attendance_change_applications_on_supervisor_id"
    t.index ["user_id"], name: "index_attendance_change_applications_on_user_id"
  end

  create_table "attendances", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "base_points", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "base_number"
    t.string "name"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "monthly_approval_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "supervisor_id", null: false
    t.date "target_month"
    t.string "status", default: "なし"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supervisor_id"], name: "index_monthly_approval_applications_on_supervisor_id"
    t.index ["user_id"], name: "index_monthly_approval_applications_on_user_id"
  end

  create_table "overtime_applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "supervisor_id", null: false
    t.bigint "attendance_id", null: false
    t.datetime "scheduled_end_time"
    t.boolean "next_day", default: false
    t.text "work_content"
    t.string "status", default: "なし"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_overtime_applications_on_attendance_id"
    t.index ["supervisor_id"], name: "index_overtime_applications_on_supervisor_id"
    t.index ["user_id"], name: "index_overtime_applications_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "department"
    t.boolean "admin", default: false
    t.datetime "basic_time"
    t.datetime "work_time"
    t.string "employee_number"
    t.string "uid"
    t.datetime "designated_work_start_time"
    t.datetime "designated_work_end_time"
    t.boolean "superior", default: false
    t.string "affiliation"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attendance_change_applications", "attendances"
  add_foreign_key "attendance_change_applications", "users"
  add_foreign_key "attendance_change_applications", "users", column: "supervisor_id"
  add_foreign_key "attendances", "users"
  add_foreign_key "monthly_approval_applications", "users"
  add_foreign_key "monthly_approval_applications", "users", column: "supervisor_id"
  add_foreign_key "overtime_applications", "attendances"
  add_foreign_key "overtime_applications", "users"
  add_foreign_key "overtime_applications", "users", column: "supervisor_id"
end
