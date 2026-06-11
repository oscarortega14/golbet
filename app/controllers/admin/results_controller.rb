module Admin
  class ResultsController < BaseController
    def index
      tournament = current_admin_tournament
      scope = tournament ? tournament.matches.includes(:home_team, :away_team).order(:kickoff_at) : Match.none
      scope = scope.where(stage: params[:stage]) if params[:stage].present?
      scope = scope.where(group: params[:group]) if params[:group].present?

      per   = 20
      page  = [params[:page].to_i, 1].max
      total = scope.count
      total_pages = [(total.to_f / per).ceil, 1].max
      page  = [page, total_pages].min
      matches = scope.limit(per).offset((page - 1) * per)

      render Views::Admin::Results::Index.new(
        matches: matches, filters: params.slice(:stage, :group).to_unsafe_h,
        current_id: tournament&.id, page: page, total_pages: total_pages
      )
    end

    def update
      match = Match.find(params[:id])
      if params[:home_score].blank? || params[:away_score].blank?
        flash[:alert] = "Marcador inválido"
        return redirect_to admin_results_path
      end
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
