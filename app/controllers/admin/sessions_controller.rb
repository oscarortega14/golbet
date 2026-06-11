module Admin
  class SessionsController < ApplicationController
    def new
      render Views::Admin::Login.new
    end

    def create
      configured = BaseController.admin_password.to_s
      if configured.present? && ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, configured)
        session[:admin] = true
        redirect_to admin_matches_path
      else
        flash.now[:alert] = "Contraseña incorrecta"
        render Views::Admin::Login.new(error: "Contraseña incorrecta"), status: :unauthorized
      end
    end

    def destroy
      session.delete(:admin)
      redirect_to admin_login_path, notice: "Sesión cerrada"
    end
  end
end
