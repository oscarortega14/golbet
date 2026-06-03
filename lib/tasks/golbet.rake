namespace :golbet do
  desc "Load World Cup teams + group fixtures (CSV) and build the knockout skeleton"
  task load_fixtures: :environment do
    tournament = Tournament.first_or_create!(name: "Mundial 2026")
    teams_csv = File.read(Rails.root.join("db/fixtures/teams.csv"))
    matches_csv = File.read(Rails.root.join("db/fixtures/group_matches.csv"))

    result = FixtureImporter.new(tournament, teams_csv: teams_csv, matches_csv: matches_csv).import
    KnockoutBracketBuilder.new(tournament).build

    if result.success?
      puts "OK: #{tournament.teams.count} teams, #{tournament.matches.count} matches " \
           "(#{tournament.matches.where(stage: 'group').count} group + " \
           "#{tournament.matches.where.not(stage: 'group').count} knockout)."
    else
      puts "Importado con #{result.errors.size} error(es):"
      result.errors.each { |e| puts "  - #{e}" }
    end
  end
end
