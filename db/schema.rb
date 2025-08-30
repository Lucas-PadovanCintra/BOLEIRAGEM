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

ActiveRecord::Schema[7.1].define(version: 2025_08_29_035519) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "match_teams", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "team_id", null: false
    t.boolean "is_team1", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_teams_on_match_id"
    t.index ["team_id"], name: "index_match_teams_on_team_id"
  end

  create_table "matches", force: :cascade do |t|
    t.string "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_contracts", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "team_id", null: false
    t.integer "matches_played", default: 0
    t.integer "contract_length", default: 5
    t.boolean "is_expired", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_expired"], name: "index_player_contracts_on_is_expired"
    t.index ["player_id"], name: "index_player_contracts_on_player_id"
    t.index ["team_id"], name: "index_player_contracts_on_team_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.integer "rating", null: false
    t.integer "price", null: false
    t.boolean "is_on_market", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "real_team_name"
    t.integer "goals"
    t.integer "assists"
    t.integer "successful_dribbles"
    t.integer "interceptions"
    t.integer "yellow_cards"
    t.integer "red_cards"
    t.integer "faults_committed"
    t.integer "loss_of_possession"
    t.integer "frequency_in_field"
    t.index ["is_on_market"], name: "index_players_on_is_on_market"
    t.index ["real_team_name"], name: "index_players_on_real_team_name"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_teams_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "balance", default: 1000
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wallets_on_user_id", unique: true
  end

  add_foreign_key "match_teams", "matches"
  add_foreign_key "match_teams", "teams"
  add_foreign_key "player_contracts", "players"
  add_foreign_key "player_contracts", "teams"
  add_foreign_key "teams", "users"
  add_foreign_key "wallets", "users"
end
