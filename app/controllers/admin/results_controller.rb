module Admin
  class ResultsController < BaseController
    def index
      tournament = Tournament.first_or_create!(name: "Torneo")
      render Views::Admin::Results::Index.new(matches: tournament.matches.order(:kickoff_at))
    end

    def update
      match = Match.find(params[:id])
      match.assign_attributes(home_score: params[:home_score], away_score: params[:away_score], status: "finished")
      if match.save
        redirect_to admin_results_path
      else
        match.restore_attributes
        flash[:alert] = match.errors.full_messages.first || "Marcador inválido"
        redirect_to admin_results_path
      end
    end
  end
end
