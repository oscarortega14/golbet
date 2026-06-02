module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    def self.admin_password
      Rails.application.config.x.admin_password
    end

    private

    def require_admin
      redirect_to admin_login_path unless session[:admin]
    end
  end
end
