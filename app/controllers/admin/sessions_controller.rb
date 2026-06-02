module Admin
  class SessionsController < ApplicationController
    def new
      render Views::Admin::Login.new
    end

    def create
      if ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, BaseController.admin_password.to_s)
        session[:admin] = true
        redirect_to admin_matches_path
      else
        flash.now[:alert] = "Contraseña incorrecta"
        render Views::Admin::Login.new(error: "Contraseña incorrecta"), status: :unauthorized
      end
    end
  end
end
