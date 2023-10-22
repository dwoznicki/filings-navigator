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
    t.text "purpose", null: false
    t.integer "cash_amount", null: false
    t.date "tax_period", null: false
    t.integer "recipient_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filings", force: :cascade do |t|
    t.datetime "return_time", null: false
    t.date "tax_period", null: false
    t.integer "filer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["return_time", "tax_period", "filer_id"], name: "index_filings_on_return_time_and_tax_period_and_filer_id", unique: true
  end

  create_table "organizations", force: :cascade do |t|
    t.integer "ein"
    t.text "name", null: false
    t.text "address_line1", null: false
    t.text "city", null: false
    t.string "state_code", limit: 2, null: false
    t.string "zip_code", limit: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ein", "name"], name: "index_organizations_on_ein_and_name", unique: true
  end

  add_foreign_key "awards", "organizations", column: "recipient_id"
  add_foreign_key "filings", "organizations", column: "filer_id"
end
