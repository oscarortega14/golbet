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

ActiveRecord::Schema[8.1].define(version: 2026_06_06_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "match_reminders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.datetime "sent_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_reminders_on_match_id"
    t.index ["player_id", "match_id"], name: "index_match_reminders_on_player_id_and_match_id", unique: true
    t.index ["player_id"], name: "index_match_reminders_on_player_id"
  end

  create_table "matches", force: :cascade do |t|
    t.string "away_label"
    t.integer "away_score"
    t.bigint "away_team_id"
    t.datetime "created_at", null: false
    t.string "group"
    t.string "home_label"
    t.integer "home_score"
    t.bigint "home_team_id"
    t.datetime "kickoff_at"
    t.integer "slot"
    t.string "stage", default: "group", null: false
    t.string "status"
    t.bigint "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "player_id", null: false
    t.bigint "pool_id", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id", "pool_id"], name: "index_memberships_on_player_id_and_pool_id", unique: true
    t.index ["player_id"], name: "index_memberships_on_player_id"
    t.index ["pool_id"], name: "index_memberships_on_pool_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "email_reminders", default: true, null: false
    t.datetime "email_verified_at"
    t.string "name"
    t.string "session_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["session_token"], name: "index_players_on_session_token", unique: true
  end

  create_table "pools", force: :cascade do |t|
    t.integer "champion_bonus", default: 15, null: false
    t.datetime "created_at", null: false
    t.integer "exact_points", default: 3, null: false
    t.bigint "focus_match_id"
    t.string "invite_token", null: false
    t.boolean "knockout_multipliers", default: true, null: false
    t.string "modality", default: "stages", null: false
    t.string "name", null: false
    t.integer "outcome_points", default: 1, null: false
    t.bigint "owner_id"
    t.boolean "public", default: false, null: false
    t.boolean "special_enabled", default: true, null: false
    t.text "stages"
    t.integer "top_scorer_bonus", default: 10, null: false
    t.bigint "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["focus_match_id"], name: "index_pools_on_focus_match_id"
    t.index ["invite_token"], name: "index_pools_on_invite_token", unique: true
    t.index ["owner_id"], name: "index_pools_on_owner_id"
    t.index ["tournament_id"], name: "index_pools_on_general_per_tournament", unique: true, where: "(public = true)"
    t.index ["tournament_id"], name: "index_pools_on_tournament_id"
  end

  create_table "predictions", force: :cascade do |t|
    t.integer "away_pred"
    t.datetime "created_at", null: false
    t.integer "home_pred"
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.bigint "pool_id", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_predictions_on_match_id"
    t.index ["player_id", "pool_id", "match_id"], name: "index_predictions_on_player_id_and_pool_id_and_match_id", unique: true
    t.index ["player_id"], name: "index_predictions_on_player_id"
    t.index ["pool_id"], name: "index_predictions_on_pool_id"
  end

  create_table "special_predictions", force: :cascade do |t|
    t.bigint "champion_team_id"
    t.datetime "created_at", null: false
    t.bigint "player_id", null: false
    t.bigint "pool_id", null: false
    t.string "top_scorer"
    t.datetime "updated_at", null: false
    t.index ["champion_team_id"], name: "index_special_predictions_on_champion_team_id"
    t.index ["player_id", "pool_id"], name: "index_special_predictions_on_player_id_and_pool_id", unique: true
    t.index ["player_id"], name: "index_special_predictions_on_player_id"
    t.index ["pool_id"], name: "index_special_predictions_on_pool_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "flag"
    t.string "group", null: false
    t.string "name", null: false
    t.bigint "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id", "code"], name: "index_teams_on_tournament_id_and_code", unique: true
    t.index ["tournament_id"], name: "index_teams_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.bigint "champion_team_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "top_scorer"
    t.datetime "updated_at", null: false
    t.index ["champion_team_id"], name: "index_tournaments_on_champion_team_id"
  end

  add_foreign_key "match_reminders", "matches"
  add_foreign_key "match_reminders", "players"
  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "memberships", "players"
  add_foreign_key "memberships", "pools"
  add_foreign_key "pools", "matches", column: "focus_match_id"
  add_foreign_key "pools", "players", column: "owner_id"
  add_foreign_key "pools", "tournaments"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "players"
  add_foreign_key "predictions", "pools"
  add_foreign_key "special_predictions", "players"
  add_foreign_key "special_predictions", "pools"
  add_foreign_key "special_predictions", "teams", column: "champion_team_id"
  add_foreign_key "teams", "tournaments"
  add_foreign_key "tournaments", "teams", column: "champion_team_id"
end
