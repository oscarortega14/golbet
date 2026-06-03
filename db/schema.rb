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

ActiveRecord::Schema[8.1].define(version: 2026_06_03_224039) do
  create_table "matches", force: :cascade do |t|
    t.string "away_label"
    t.integer "away_score"
    t.integer "away_team_id"
    t.datetime "created_at", null: false
    t.string "group"
    t.string "home_label"
    t.integer "home_score"
    t.integer "home_team_id"
    t.datetime "kickoff_at"
    t.integer "slot"
    t.string "stage", default: "group", null: false
    t.string "status"
    t.integer "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "email_verified_at"
    t.string "name"
    t.string "session_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["session_token"], name: "index_players_on_session_token", unique: true
  end

  create_table "predictions", force: :cascade do |t|
    t.integer "away_pred"
    t.datetime "created_at", null: false
    t.integer "home_pred"
    t.integer "match_id", null: false
    t.integer "player_id", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_predictions_on_match_id"
    t.index ["player_id", "match_id"], name: "index_predictions_on_player_id_and_match_id", unique: true
    t.index ["player_id"], name: "index_predictions_on_player_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "flag"
    t.string "group", null: false
    t.string "name", null: false
    t.integer "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id", "code"], name: "index_teams_on_tournament_id_and_code", unique: true
    t.index ["tournament_id"], name: "index_teams_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.integer "champion_team_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "top_scorer"
    t.datetime "updated_at", null: false
    t.index ["champion_team_id"], name: "index_tournaments_on_champion_team_id"
  end

  add_foreign_key "matches", "teams", column: "away_team_id"
  add_foreign_key "matches", "teams", column: "home_team_id"
  add_foreign_key "matches", "tournaments"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "players"
  add_foreign_key "teams", "tournaments"
  add_foreign_key "tournaments", "teams", column: "champion_team_id"
end
