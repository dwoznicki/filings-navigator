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

ActiveRecord::Schema[7.0].define(version: 2023_10_20_073529) do
  create_table "awards", force: :cascade do |t|
    t.text "purpose"
    t.integer "cash_amount"
    t.date "tax_period"
    t.integer "recipient_ein"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filings", force: :cascade do |t|
    t.datetime "return_time"
    t.date "tax_period"
    t.integer "filer_ein"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organizations", primary_key: "ein", force: :cascade do |t|
    t.text "name"
    t.text "address_line1"
    t.text "city"
    t.string "state_code", limit: 2
    t.string "zip_code", limit: 10
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "awards", "organizations", column: "recipient_ein", primary_key: "ein"
  add_foreign_key "filings", "organizations", column: "filer_ein", primary_key: "ein"
end
