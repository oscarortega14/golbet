class GroupsController < ApplicationController
  before_action :require_player

  def index
    tournament = current_pool&.tournament
    standings = tournament ? GroupStandingsService.for(tournament) : {}
    render Views::Groups::Index.new(standings: standings)
  end
end
