class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_player
  helper_method :current_pool

  def current_player
    return @current_player if defined?(@current_player)
    @current_player = Player.find_by(session_token: cookies.signed[:player_token])
  end

  def current_pool
    return @current_pool if defined?(@current_pool)
    return @current_pool = nil unless current_player
    @current_pool = current_player.pools.find_by(id: session[:pool_id]) || general_pool
  end

  def general_pool
    return nil unless Tournament.exists?
    Pool.general || Pool.create!(name: "Mundial — General", tournament: Tournament.first, public: true)
  end

  def ensure_general_membership
    pool = general_pool
    Membership.find_or_create_by!(player: current_player, pool: pool) if pool && current_player
  end

  def require_player
    if current_player
      ensure_general_membership
    else
      redirect_to root_path
    end
  end
end
