# Idempotent demo data for local play.
t = Tournament.first_or_create!(name: "Mundial 2026")

# --- Matches -----------------------------------------------------------------
# Finished (with results) -> populate the ranking/podium.
finished = [
  { home: "Argentina", away: "Brasil",  hs: 2, as: 1, hours_ago: 3 },
  { home: "España",    away: "Francia", hs: 0, as: 0, hours_ago: 2 },
  { home: "Uruguay",   away: "Chile",   hs: 3, as: 1, hours_ago: 1 },
]
# Upcoming (scheduled) -> show on the predictions page.
upcoming = [
  { home: "México",   away: "Estados Unidos", in_days: 2 },
  { home: "Colombia", away: "Ecuador",        in_days: 3 },
]

fmatches = finished.map do |f|
  match = t.matches.find_or_create_by!(home_team: f[:home], away_team: f[:away]) do |m|
    m.kickoff_at = f[:hours_ago].hours.ago
  end
  match.update!(home_score: f[:hs], away_score: f[:as], status: "finished",
                kickoff_at: f[:hours_ago].hours.ago)
  match
end

upcoming.each do |u|
  match = t.matches.find_or_create_by!(home_team: u[:home], away_team: u[:away]) do |m|
    m.kickoff_at = u[:in_days].days.from_now
  end
  match.update!(status: "scheduled", home_score: nil, away_score: nil,
                kickoff_at: u[:in_days].days.from_now)
end

# --- Players + predictions (totals: Ana 9, Diego 5, Beto 3, Caro 1, Oscar 0) --
predictions = {
  "Ana"   => [[2, 1], [0, 0], [3, 1]],
  "Diego" => [[2, 1], [1, 1], [2, 0]],
  "Beto"  => [[1, 0], [2, 2], [1, 0]],
  "Caro"  => [[5, 0], [2, 1], [0, 2]],
  "Oscar" => [[0, 3], [1, 2], [0, 5]],
}

predictions.each do |name, scores|
  player = Player.find_or_create_by!(name: name)
  scores.each_with_index do |(hp, ap), i|
    match = fmatches[i]
    next if Prediction.exists?(player: player, match: match)
    # Matches are already finished (locked), so bypass the kickoff-lock validation
    # that only applies to live user submissions.
    Prediction.new(player: player, match: match, home_pred: hp, away_pred: ap).save!(validate: false)
  end
end

puts "Seeded: #{Tournament.count} tournament, #{Match.count} matches, " \
     "#{Player.count} players, #{Prediction.count} predictions."
