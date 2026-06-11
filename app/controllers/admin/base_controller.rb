module Admin
  class BaseController < ApplicationController
    before_action :require_admin
    before_action :remember_admin_tournament
    helper_method :current_admin_tournament

    def self.admin_password
      Rails.application.config.x.admin_password
    end

    def current_admin_tournament
      @current_admin_tournament ||=
        Tournament.find_by(id: session[:admin_tournament_id]) || Tournament.active || Tournament.first
    end

    private

    def require_admin
      redirect_to admin_login_path unless session[:admin]
    end

    # Mantiene en sesión el último torneo visitado (desde la URL anidada
    # /admin/tournaments/:tournament_id/...) para que el sidebar y los fallbacks
    # apunten al torneo en gestión.
    def remember_admin_tournament
      id = params[:tournament_id].presence
      if id.present? && Tournament.exists?(id: id)
        session[:admin_tournament_id] = id.to_i
        @current_admin_tournament = nil
      end
    end
  end
end
