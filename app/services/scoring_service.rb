class ScoringService
  EXACT = 3
  OUTCOME = 1
  MISS = 0

  CHAMPION_BONUS = 15
  TOP_SCORER_BONUS = 10

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

  def self.special_points(special_prediction, tournament)
    return 0 if special_prediction.nil?
    pts = 0
    if tournament.champion_team_id.present? && special_prediction.champion_team_id == tournament.champion_team_id
      pts += CHAMPION_BONUS
    end
    if tournament.top_scorer.present? && special_prediction.top_scorer.present? &&
       SpecialPrediction.normalize(special_prediction.top_scorer) == SpecialPrediction.normalize(tournament.top_scorer)
      pts += TOP_SCORER_BONUS
    end
    pts
  end

  def self.standings(pool)
    tournament = pool.tournament
    finished = tournament.matches.where(status: "finished").to_a
    by_match = finished.index_by(&:id)

    totals = Hash.new(0)
    players = {}

    pool.predictions.where(match_id: by_match.keys).includes(:player).each do |pred|
      players[pred.player_id] ||= pred.player
      totals[pred.player_id] += match_points(pred, by_match[pred.match_id])
    end

    pool.special_predictions.includes(:player).each do |sp|
      bonus = special_points(sp, tournament)
      next unless bonus.positive?
      players[sp.player_id] ||= sp.player
      totals[sp.player_id] += bonus
    end

    totals.map { |player_id, points| { player: players[player_id], points: points } }
          .sort_by { |row| [-row[:points], row[:player].name] }
  end
end
