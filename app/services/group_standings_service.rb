class GroupStandingsService
  def self.for(tournament) = new(tournament).call

  def initialize(tournament) = @tournament = tournament

  def call
    teams_by_group = @tournament.teams.group_by(&:group)
    finished = @tournament.matches.where(stage: "group", status: "finished")
                          .includes(:home_team, :away_team).to_a

    teams_by_group.transform_values do |teams|
      rows = teams.to_h { |t| [t.id, blank_row(t)] }
      finished.each { |m| tally(rows, m) }
      rows.values.sort_by { |r| [-r[:pts], -r[:dg], -r[:gf], r[:team].name] }
    end.sort.to_h
  end

  private

  def blank_row(team)
    { team: team, pj: 0, g: 0, e: 0, p: 0, gf: 0, gc: 0, dg: 0, pts: 0 }
  end

  def tally(rows, match)
    h = rows[match.home_team_id]
    a = rows[match.away_team_id]
    return unless h && a

    hs, as = match.home_score, match.away_score
    [[h, hs, as], [a, as, hs]].each do |row, gf, gc|
      row[:pj] += 1; row[:gf] += gf; row[:gc] += gc; row[:dg] = row[:gf] - row[:gc]
    end
    if hs > as
      h[:g] += 1; h[:pts] += 3; a[:p] += 1
    elsif hs < as
      a[:g] += 1; a[:pts] += 3; h[:p] += 1
    else
      h[:e] += 1; a[:e] += 1; h[:pts] += 1; a[:pts] += 1
    end
  end
end
