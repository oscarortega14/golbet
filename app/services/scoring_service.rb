class ScoringService
  EXACT = 3
  OUTCOME = 1
  MISS = 0

  STAGE_MULTIPLIER = {
    "group" => 1, "round_of_32" => 1, "round_of_16" => 2,
    "quarter_final" => 3, "semi_final" => 4, "third_place" => 2, "final" => 5
  }.freeze

  def self.points_for(prediction, match)
    return MISS unless match.finished?
    return MISS if prediction.home_pred.nil? || prediction.away_pred.nil?

    if prediction.home_pred == match.home_score && prediction.away_pred == match.away_score
      EXACT
    elsif sign(prediction.home_pred - prediction.away_pred) == sign(match.home_score - match.away_score)
      OUTCOME
    else
      MISS
    end
  end

  def self.sign(n)
    n <=> 0
  end

  def self.match_points(prediction, match)
    points_for(prediction, match) * STAGE_MULTIPLIER.fetch(match.stage, 1)
  end

  def self.standings(tournament)
    finished = tournament.matches.where(status: "finished").to_a
    by_match = finished.index_by(&:id)

    totals = Hash.new(0)   # player_id => points
    players = {}           # player_id => Player

    Prediction.where(match_id: by_match.keys).includes(:player).each do |pred|
      players[pred.player_id] ||= pred.player
      totals[pred.player_id] += match_points(pred, by_match[pred.match_id])
    end

    totals.map { |player_id, points| { player: players[player_id], points: points } }
          .sort_by { |row| [-row[:points], row[:player].name] }
  end
end
