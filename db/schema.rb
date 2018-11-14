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

ActiveRecord::Schema.define(version: 2018_11_14_154842) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "agencies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apartments", force: :cascade do |t|
    t.string "street"
    t.string "zipcode"
    t.string "city"
    t.string "state"
    t.float "latitude"
    t.float "longitude"
    t.string "url"
    t.integer "zillow_id"
    t.integer "value"
    t.boolean "price_change"
    t.integer "sqft"
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "year_built"
    t.string "images", default: [], array: true
    t.string "description"
    t.integer "neighborhood_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "complaints", force: :cascade do |t|
    t.string "name"
    t.bigint "agency_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_complaints_on_agency_id"
  end

  create_table "incidents", force: :cascade do |t|
    t.bigint "complaint_id"
    t.bigint "agency_id"
    t.bigint "neighborhood_id"
    t.datetime "date_opened"
    t.datetime "date_closed"
    t.string "descriptor"
    t.float "latitude"
    t.float "longitude"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.boolean "status"
    t.string "zip"
    t.string "incident_address"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agency_id"], name: "index_incidents_on_agency_id"
    t.index ["complaint_id"], name: "index_incidents_on_complaint_id"
    t.index ["neighborhood_id"], name: "index_incidents_on_neighborhood_id"
  end

  create_table "journeys", force: :cascade do |t|
    t.integer "neighborhood_a_id"
    t.integer "neighborhood_b_id"
    t.integer "trip_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_a_id", "neighborhood_b_id"], name: "index_journeys_on_neighborhood_a_id_and_neighborhood_b_id", unique: true
    t.index ["neighborhood_a_id"], name: "index_journeys_on_neighborhood_a_id"
    t.index ["neighborhood_b_id"], name: "index_journeys_on_neighborhood_b_id"
  end

  create_table "neighborhoods", force: :cascade do |t|
    t.string "name"
    t.string "county"
    t.string "regionid"
    t.geometry "geom", limit: {:srid=>4326, :type=>"multi_polygon"}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "neighborhood_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["neighborhood_id"], name: "index_searches_on_neighborhood_id"
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "user_apartments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "apartment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apartment_id"], name: "index_user_apartments_on_apartment_id"
    t.index ["user_id"], name: "index_user_apartments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "complaints", "agencies"
  add_foreign_key "incidents", "agencies"
  add_foreign_key "incidents", "complaints"
  add_foreign_key "incidents", "neighborhoods"
  add_foreign_key "searches", "neighborhoods"
  add_foreign_key "searches", "users"
  add_foreign_key "user_apartments", "apartments"
  add_foreign_key "user_apartments", "users"
end
