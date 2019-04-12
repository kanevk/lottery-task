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

ActiveRecord::Schema.define(version: 2019_04_12_195503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "lotteries", force: :cascade do |t|
    t.datetime "drawn_on"
    t.jsonb "winning_numbers"
  end

  create_table "lottery_tickets", force: :cascade do |t|
    t.string "nickname", null: false
    t.bigint "lottery_id", null: false
    t.jsonb "numbers"
    t.bit_varying "bit_serialized_numbers", limit: 50
    t.index ["lottery_id"], name: "index_lottery_tickets_on_lottery_id"
  end

  add_foreign_key "lottery_tickets", "lotteries"
end
