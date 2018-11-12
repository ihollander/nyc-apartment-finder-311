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

ActiveRecord::Schema.define(version: 2018_11_09_221119) do

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "boroughs", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaints", force: :cascade do |t|
    t.string "name"
    t.integer "agency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_complaints_on_agency_id"
  end

  create_table "csv_tables", force: :cascade do |t|
    t.string "agency_name"
    t.string "borough"
    t.string "closed_date"
    t.string "complaint_type"
    t.string "created_date"
    t.string "descriptor"
    t.string "latitude"
    t.string "longitude"
    t.string "status"
    t.string "resolution_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "incidents", force: :cascade do |t|
    t.integer "complaint_id"
    t.integer "agency_id"
    t.integer "borough_id"
    t.datetime "date_opened"
    t.datetime "date_closed"
    t.string "descriptor"
    t.float "latitude"
    t.float "longitude"
    t.boolean "status"
    t.string "zip"
    t.string "incident_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_incidents_on_agency_id"
    t.index ["borough_id"], name: "index_incidents_on_borough_id"
    t.index ["complaint_id"], name: "index_incidents_on_complaint_id"
  end

  create_table "searches", force: :cascade do |t|
    t.integer "user_id"
    t.integer "borough_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borough_id"], name: "index_searches_on_borough_id"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
