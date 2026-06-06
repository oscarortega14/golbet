# frozen_string_literal: true

module Admin
  class ResolutionsController < BaseController
    def show
      render Views::Admin::Resolutions::Show.new(tournament: tournament, teams: tournament.teams.order(:group, :name))
    end

    def update
      tournament.update!(
        champion_team_id: params[:champion_team_id].presence,
        top_scorer: params[:top_scorer].presence
      )
      redirect_to admin_resolution_path, notice: "Resultado del torneo guardado."
    end

    private

    def tournament = current_admin_tournament
  end
end
