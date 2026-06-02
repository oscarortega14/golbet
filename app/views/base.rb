# frozen_string_literal: true

class Views::Base < Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache

  # Shared section heading for the inner pages.
  def page_header(title, subtitle = nil)
    header(class: "mb-6") do
      h2(class: "font-display text-3xl text-foreground") { title }
      p(class: "mt-1 text-sm text-muted-foreground") { subtitle } if subtitle
    end
  end
end
