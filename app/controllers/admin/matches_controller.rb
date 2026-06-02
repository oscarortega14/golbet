module Admin
  class MatchesController < BaseController
    def index
      @tournament = Tournament.first_or_create!(name: "Torneo")
      render Views::Admin::Matches::Index.new(tournament: @tournament)
    end

    def new
      render Views::Admin::Matches::Form.new(match: Match.new)
    end

    def create
      tournament = Tournament.first_or_create!(name: "Torneo")
      match = tournament.matches.new(match_params)
      if match.save
        redirect_to admin_matches_path
      else
        render Views::Admin::Matches::Form.new(match: match), status: :unprocessable_entity
      end
    end

    def edit
      render Views::Admin::Matches::Form.new(match: Match.find(params[:id]))
    end

    def update
      match = Match.find(params[:id])
      if match.update(match_params)
        redirect_to admin_matches_path
      else
        render Views::Admin::Matches::Form.new(match: match), status: :unprocessable_entity
      end
    end

    private

    def match_params
      params.require(:match).permit(:home_team, :away_team, :kickoff_at)
    end
  end
end
