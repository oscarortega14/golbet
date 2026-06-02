# Idempotent seed data for local play.
t = Tournament.first_or_create!(name: "Mundial 2026")

if t.matches.empty?
  t.matches.create!(home_team: "Argentina", away_team: "Brasil",  kickoff_at: 2.days.from_now)
  t.matches.create!(home_team: "España",     away_team: "Francia", kickoff_at: 3.days.from_now)
  t.matches.create!(home_team: "Uruguay",    away_team: "Chile",   kickoff_at: 4.days.from_now)
end
