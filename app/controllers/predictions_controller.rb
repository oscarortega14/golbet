class PredictionsController < ApplicationController
  before_action :require_player

  def index
    @tournament = Tournament.first
    @matches = @tournament ? @tournament.matches.order(:kickoff_at) : []
    @predictions = current_player.predictions.index_by(&:match_id)
    render Views::Predictions::Index.new(matches: @matches, predictions: @predictions, flash: flash)
  end

  def create
    match = Match.find(params[:match_id])
    prediction = current_player.predictions.find_or_initialize_by(match: match)
    prediction.assign_attributes(home_pred: params[:home_pred], away_pred: params[:away_pred])

    if prediction.save
      flash[:notice] = "¡Pronóstico guardado!"
    else
      flash[:alert] = prediction.errors.full_messages.first
    end
    redirect_to predictions_path
  end
end
