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

ActiveRecord::Schema[8.1].define(version: 2026_06_02_040055) do
  create_table "matches", force: :cascade do |t|
    t.integer "away_score"
    t.string "away_team"
    t.datetime "created_at", null: false
    t.integer "home_score"
    t.string "home_team"
    t.datetime "kickoff_at"
    t.string "status"
    t.integer "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id"], name: "index_matches_on_tournament_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "session_token"
    t.datetime "updated_at", null: false
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

  create_table "tournaments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "matches", "tournaments"
  add_foreign_key "predictions", "matches"
  add_foreign_key "predictions", "players"
end
