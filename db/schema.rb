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

ActiveRecord::Schema[7.0].define(version: 2026_09_23_043625) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id", "name"], name: "index_menu_items_on_shop_id_and_name", unique: true
    t.index ["shop_id"], name: "index_menu_items_on_shop_id"
  end

  create_table "review_replies", force: :cascade do |t|
    t.integer "review_id", null: false
    t.integer "shop_owner_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["review_id"], name: "index_review_replies_on_review_id", unique: true
    t.index ["shop_owner_id"], name: "index_review_replies_on_shop_owner_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "shop_id", null: false
    t.text "content"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_reviews_on_shop_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "shop_owners", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "status", default: "pending", null: false
    t.index ["shop_id"], name: "index_shop_owners_on_shop_id"
    t.index ["user_id", "shop_id"], name: "index_shop_owners_on_user_id_and_shop_id", unique: true
    t.index ["user_id"], name: "index_shop_owners_on_user_id"
  end

  create_table "shop_submissions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.string "address"
    t.text "description"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shop_submissions_on_user_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.text "description"
    t.boolean "egg_free", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.string "owner_code"
    t.index ["name", "address"], name: "index_shops_on_name_and_address", unique: true
    t.index ["owner_code"], name: "index_shops_on_owner_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "withdrawn_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "verifications", force: :cascade do |t|
    t.integer "shop_id", null: false
    t.integer "menu_item_id"
    t.string "category"
    t.string "egg_status"
    t.string "source_type"
    t.string "verification_method"
    t.date "verified_on"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "status", default: "pending", null: false
    t.index ["menu_item_id"], name: "index_verifications_on_menu_item_id"
    t.index ["shop_id"], name: "index_verifications_on_shop_id"
    t.index ["status"], name: "index_verifications_on_status"
    t.index ["user_id"], name: "index_verifications_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "menu_items", "shops"
  add_foreign_key "review_replies", "reviews"
  add_foreign_key "review_replies", "shop_owners"
  add_foreign_key "reviews", "shops"
  add_foreign_key "reviews", "users"
  add_foreign_key "shop_owners", "shops"
  add_foreign_key "shop_owners", "users"
  add_foreign_key "shop_submissions", "users"
  add_foreign_key "verifications", "menu_items"
  add_foreign_key "verifications", "shops"
  add_foreign_key "verifications", "users"
end
