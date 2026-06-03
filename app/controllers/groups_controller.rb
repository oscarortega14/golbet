class GroupsController < ApplicationController
  before_action :require_player

  def index
    tournament = Tournament.first
    standings = tournament ? GroupStandingsService.for(tournament) : {}
    render Views::Groups::Index.new(standings: standings)
  end
end
