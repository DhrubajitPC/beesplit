# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160326193915) do

  create_table "all_stores", force: :cascade do |t|
    t.integer  "store_id",   limit: 4
    t.string   "address",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "bees", force: :cascade do |t|
    t.integer  "order_id",     limit: 4
    t.string   "rating",       limit: 255
    t.integer  "status",       limit: 4
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.string   "contact",      limit: 255
    t.integer  "all_store_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "items", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "price",      limit: 255
    t.string   "category",   limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "order_alls", force: :cascade do |t|
		t.integer	 "parent_id", 		limit: 4
		t.integer  "bee_id",        limit: 4
		t.string   "address",    		limit: 255
		t.datetime "delivery_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "quantity",      limit: 4
    t.integer  "item_id",       limit: 4
    t.integer  "order_all_id",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "stores", force: :cascade do |t|
    t.integer  "item_id",      limit: 4
    t.integer  "all_store_id", limit: 4
    t.integer  "stock",        limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
