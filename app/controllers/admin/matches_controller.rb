module Admin
  class MatchesController < BaseController
    def index
      @tournament = current_admin_tournament
      scope = @tournament ? @tournament.matches.includes(:home_team, :away_team).order(:kickoff_at) : Match.none
      scope = scope.where(stage: params[:stage]) if params[:stage].present?
      scope = scope.where(group: params[:group]) if params[:group].present?
      render Views::Admin::Matches::Index.new(tournament: @tournament, matches: scope, filters: params.slice(:stage, :group).to_unsafe_h)
    end

    def edit
      render Views::Admin::Matches::Form.new(match: Match.find(params[:id]), teams: teams)
    end

    def update
      match = Match.find(params[:id])
      if match.update(match_params)
        redirect_to admin_matches_path
      else
        render Views::Admin::Matches::Form.new(match: match, teams: teams), status: :unprocessable_entity
      end
    end

    private

    def teams = (current_admin_tournament&.teams&.order(:group, :name) || [])

    def match_params
      params.require(:match).permit(:home_team_id, :away_team_id, :kickoff_at, :stage, :group)
    end
  end
end
