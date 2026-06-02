class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_player

  def current_player
    return @current_player if defined?(@current_player)
    @current_player = Player.find_by(session_token: cookies.signed[:player_token])
  end

  def require_player
    redirect_to root_path unless current_player
  end
end
