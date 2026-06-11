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
      redirect_to admin_matches_path, notice: "Gestionando \"#{tournament.name}\"."
    end

    def import_fixtures
      tournament = Tournament.find(params[:id])
      teams_csv = params[:teams_csv]&.read&.force_encoding("UTF-8")
      matches_csv = params[:matches_csv]&.read&.force_encoding("UTF-8")
      if teams_csv.blank? || matches_csv.blank?
        redirect_to admin_tournaments_path, alert: "Sube ambos CSV (equipos y partidos)." and return
      end
      result = FixtureImporter.new(tournament, teams_csv: teams_csv, matches_csv: matches_csv).import
      KnockoutBracketBuilder.new(tournament).build
      if result.success?
        redirect_to admin_tournaments_path, notice: "Fixtures cargados en #{tournament.name}."
      else
        redirect_to admin_tournaments_path, alert: "Errores: #{result.errors.first}"
      end
    end
  end
end
