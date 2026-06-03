require "csv"

class FixtureImporter
  Result = Struct.new(:errors) do
    def success? = errors.empty?
  end

  def initialize(tournament, teams_csv:, matches_csv:)
    @tournament = tournament
    @teams_csv = teams_csv
    @matches_csv = matches_csv
    @errors = []
  end

  def import
    import_teams
    import_matches
    Result.new(@errors)
  end

  private

  def import_teams
    CSV.parse(@teams_csv, headers: true).each_with_index do |row, i|
      team = @tournament.teams.find_or_initialize_by(code: row["code"])
      team.assign_attributes(name: row["name"], flag: row["flag"], group: row["group"])
      team.save!
    rescue => e
      @errors << "teams.csv fila #{i + 2}: #{e.message}"
    end
  end

  def import_matches
    by_code = @tournament.teams.index_by(&:code)
    CSV.parse(@matches_csv, headers: true).each_with_index do |row, i|
      home = by_code[row["home_code"]]
      away = by_code[row["away_code"]]
      unless home && away
        @errors << "group_matches.csv fila #{i + 2}: código desconocido (#{row["home_code"]} / #{row["away_code"]})"
        next
      end
      match = @tournament.matches.find_or_initialize_by(stage: "group", home_team: home, away_team: away)
      match.assign_attributes(group: row["group"], kickoff_at: Time.zone.parse(row["kickoff_at"]))
      match.save!
    rescue => e
      @errors << "group_matches.csv fila #{i + 2}: #{e.message}"
    end
  end
end
