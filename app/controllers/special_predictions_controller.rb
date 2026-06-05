class SpecialPredictionsController < ApplicationController
  before_action :require_player

  def create
    sp = current_player.special_predictions.find_or_initialize_by(pool: current_pool)
    sp.assign_attributes(champion_team_id: params[:champion_team_id].presence,
                         top_scorer: params[:top_scorer].presence)
    if sp.save
      flash[:notice] = "¡Predicción especial guardada!"
    else
      flash[:alert] = sp.errors.full_messages.first
    end
    redirect_to predictions_path
  end
end
