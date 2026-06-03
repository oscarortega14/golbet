class PredictionsController < ApplicationController
  before_action :require_player

  STAGE_LABELS = {
    "group" => "Fase de grupos", "round_of_32" => "Dieciseisavos",
    "round_of_16" => "Octavos", "quarter_final" => "Cuartos",
    "semi_final" => "Semifinal", "third_place" => "Tercer puesto", "final" => "Final"
  }.freeze

  def index
    @tournament = Tournament.first
    matches = @tournament ? @tournament.matches.includes(:home_team, :away_team).order(:kickoff_at) : []
    grouped = matches.group_by(&:stage)
                     .sort_by { |stage, _| Match::STAGES.index(stage) }
                     .to_h
                     .transform_keys { |s| STAGE_LABELS[s] || s }
    special = @tournament && current_player.special_predictions.find_or_initialize_by(tournament: @tournament)
    render Views::Predictions::Index.new(
      grouped: grouped,
      predictions: current_player.predictions.index_by(&:match_id),
      special: special,
      teams: @tournament ? @tournament.teams.order(:group, :name) : [],
      tournament: @tournament,
      flash: { notice: flash[:notice], alert: flash[:alert] }
    )
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
