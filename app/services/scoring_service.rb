class ScoringService
  EXACT = 3
  OUTCOME = 1
  MISS = 0

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
end
