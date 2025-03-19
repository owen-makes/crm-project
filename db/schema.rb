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

ActiveRecord::Schema[7.2].define(version: 2025_03_19_131354) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.string "phone"
    t.string "channel"
    t.string "broker"
    t.string "email"
    t.text "notes"
    t.text "goals"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "team_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "csv_imports", force: :cascade do |t|
    t.string "file"
    t.json "headers"
    t.json "data"
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_csv_imports_on_team_id"
    t.index ["user_id"], name: "index_csv_imports_on_user_id"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "symbol"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.decimal "rate", precision: 19, scale: 4
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "base_currency_id"
    t.bigint "target_currency_id"
    t.string "rate_type"
    t.index ["base_currency_id"], name: "index_exchange_rates_on_base_currency_id"
    t.index ["date", "base_currency_id", "target_currency_id"], name: "idx_on_date_base_currency_id_target_currency_id_c5ec45c0ee", unique: true
    t.index ["target_currency_id"], name: "index_exchange_rates_on_target_currency_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string "name"
    t.string "country_code"
    t.string "acronym"
    t.string "mic_code"
    t.string "city"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holdings", force: :cascade do |t|
    t.decimal "quantity", precision: 18, scale: 8
    t.decimal "cost_basis", precision: 19, scale: 4
    t.bigint "portfolio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "security_id"
    t.index ["portfolio_id"], name: "index_holdings_on_portfolio_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.string "phone"
    t.string "status"
    t.string "channel"
    t.decimal "capital", precision: 19, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "email"
    t.bigint "user_id", null: false
    t.string "broker"
    t.text "notes"
    t.integer "team_id"
    t.index ["user_id"], name: "index_leads_on_user_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "broker"
    t.string "account_number"
    t.string "name"
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "currency_id"
    t.string "country"
    t.index ["client_id"], name: "index_portfolios_on_client_id"
    t.index ["currency_id"], name: "index_portfolios_on_currency_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "securities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ticker"
    t.string "name"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "security_type"
    t.bigint "currency_id", null: false
    t.text "description"
    t.bigint "exchange_id", null: false
    t.jsonb "details"
    t.index ["currency_id"], name: "index_securities_on_currency_id"
    t.index ["exchange_id"], name: "index_securities_on_exchange_id"
  end

  create_table "security_prices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "security_id", null: false
    t.date "date"
    t.decimal "price", precision: 19, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "currency_id"
    t.index ["currency_id"], name: "index_security_prices_on_currency_id"
    t.index ["security_id"], name: "index_security_prices_on_security_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "join_token"
    t.index ["admin_id"], name: "index_teams_on_admin_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_type"
    t.datetime "date"
    t.decimal "quantity", precision: 18, scale: 8
    t.decimal "price", precision: 19, scale: 4
    t.decimal "fees", precision: 19, scale: 4
    t.bigint "currency_id", null: false
    t.bigint "portfolio_id", null: false
    t.uuid "security_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_transactions_on_currency_id"
    t.index ["portfolio_id"], name: "index_transactions_on_portfolio_id"
    t.index ["security_id"], name: "index_transactions_on_security_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "last_name"
    t.string "form_token"
    t.integer "role"
    t.integer "team_id"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "emoji"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["form_token"], name: "index_users_on_form_token", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clients", "users"
  add_foreign_key "csv_imports", "teams"
  add_foreign_key "csv_imports", "users"
  add_foreign_key "exchange_rates", "currencies", column: "base_currency_id"
  add_foreign_key "exchange_rates", "currencies", column: "target_currency_id"
  add_foreign_key "holdings", "portfolios"
  add_foreign_key "holdings", "securities"
  add_foreign_key "leads", "users"
  add_foreign_key "portfolios", "clients"
  add_foreign_key "portfolios", "currencies"
  add_foreign_key "profiles", "users"
  add_foreign_key "securities", "currencies"
  add_foreign_key "securities", "exchanges"
  add_foreign_key "security_prices", "currencies"
  add_foreign_key "security_prices", "securities"
  add_foreign_key "teams", "users", column: "admin_id"
  add_foreign_key "transactions", "currencies"
  add_foreign_key "transactions", "portfolios"
  add_foreign_key "transactions", "securities"
end
