module Admin
  class BaseController < ApplicationController
    before_action :require_admin
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
  end
end
