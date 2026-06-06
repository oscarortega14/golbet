module Admin
  class TournamentsController < BaseController
    def index
      render Views::Admin::Tournaments::Index.new(
        tournaments: Tournament.order(active: :desc, name: :asc).to_a,
        current_id: current_admin_tournament&.id
      )
    end

    def create
      name = params[:name].to_s.strip
      if name.blank?
        redirect_to admin_tournaments_path, alert: "El nombre es obligatorio." and return
      end
      tournament = Tournament.create!(name: name)
      general_pool_for(tournament) # crea la General pública
      session[:admin_tournament_id] = tournament.id
      redirect_to admin_tournaments_path, notice: "Torneo \"#{tournament.name}\" creado."
    end

    def activate
      tournament = Tournament.find(params[:id])
      tournament.activate!
      redirect_to admin_tournaments_path, notice: "\"#{tournament.name}\" es ahora el torneo activo."
    end

    def select
      tournament = Tournament.find(params[:id])
      session[:admin_tournament_id] = tournament.id
      redirect_back fallback_location: admin_tournaments_path
    end
  end
end
