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

ActiveRecord::Schema[7.1].define(version: 2024_10_17_100557) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
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
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "archives", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "user_id", null: false
    t.bigint "record_id", null: false
    t.jsonb "record_data"
    t.datetime "deleted_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_archives_on_branch_id"
    t.index ["record_id"], name: "index_archives_on_record_id"
    t.index ["user_id"], name: "index_archives_on_user_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "cashier_id", null: false
    t.bigint "record_id", null: false
    t.bigint "medicine_id", null: false
    t.integer "quantity_sold"
    t.decimal "total_amount"
    t.datetime "audited_from"
    t.datetime "audited_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_id"
    t.index ["branch_id"], name: "index_audit_logs_on_branch_id"
    t.index ["cashier_id"], name: "index_audit_logs_on_cashier_id"
    t.index ["medicine_id"], name: "index_audit_logs_on_medicine_id"
    t.index ["record_id"], name: "index_audit_logs_on_record_id"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_admin_id"
  end

  create_table "disputes", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "record_id", null: false
    t.string "reason", null: false
    t.integer "status", default: 0
    t.string "pdf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_disputes_on_branch_id"
    t.index ["record_id"], name: "index_disputes_on_record_id"
  end

  create_table "medicines", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "price"
    t.integer "stock_quantity"
    t.date "expiry_date"
    t.bigint "branch_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "expired", default: false
    t.string "sku"
    t.index ["branch_id"], name: "index_medicines_on_branch_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.bigint "branch_id"
    t.datetime "read_at"
    t.index ["branch_id"], name: "index_notifications_on_branch_id"
    t.index ["customer_id"], name: "index_notifications_on_customer_id"
  end

  create_table "record_items", force: :cascade do |t|
    t.bigint "record_id", null: false
    t.bigint "medicine_id", null: false
    t.integer "quantity"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["medicine_id"], name: "index_record_items_on_medicine_id"
    t.index ["record_id"], name: "index_record_items_on_record_id"
  end

  create_table "records", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "cashier_id", null: false
    t.bigint "branch_id", null: false
    t.float "total_amount"
    t.integer "payment_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.string "house_no"
    t.string "postal_code"
    t.string "address"
    t.datetime "deleted_at"
    t.string "payment_intent_id"
    t.index ["branch_id"], name: "index_records_on_branch_id"
    t.index ["cashier_id"], name: "index_records_on_cashier_id"
    t.index ["customer_id"], name: "index_records_on_customer_id"
  end

  create_table "refunds", force: :cascade do |t|
    t.bigint "record_id", null: false
    t.integer "status", default: 0
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_id"
    t.integer "customer_id"
    t.index ["record_id"], name: "index_refunds_on_record_id"
  end

  create_table "stock_transfers", force: :cascade do |t|
    t.bigint "requesting_branch_id", null: false
    t.bigint "receiving_branch_id", null: false
    t.integer "status", default: 0
    t.jsonb "medicines"
    t.string "pdf"
    t.index ["receiving_branch_id"], name: "index_stock_transfers_on_receiving_branch_id"
    t.index ["requesting_branch_id"], name: "index_stock_transfers_on_requesting_branch_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.integer "role", default: 3, null: false
    t.bigint "branch_id"
    t.string "name"
    t.index ["branch_id"], name: "index_users_on_branch_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "archives", "branches"
  add_foreign_key "archives", "records"
  add_foreign_key "archives", "users"
  add_foreign_key "audit_logs", "branches"
  add_foreign_key "audit_logs", "medicines"
  add_foreign_key "audit_logs", "records"
  add_foreign_key "audit_logs", "users", column: "cashier_id"
  add_foreign_key "disputes", "branches"
  add_foreign_key "disputes", "records"
  add_foreign_key "medicines", "branches"
  add_foreign_key "notifications", "branches"
  add_foreign_key "notifications", "users", column: "customer_id"
  add_foreign_key "record_items", "medicines"
  add_foreign_key "record_items", "records"
  add_foreign_key "records", "branches"
  add_foreign_key "records", "users", column: "cashier_id"
  add_foreign_key "records", "users", column: "customer_id"
  add_foreign_key "refunds", "records"
  add_foreign_key "stock_transfers", "branches", column: "receiving_branch_id"
  add_foreign_key "stock_transfers", "branches", column: "requesting_branch_id"
end
