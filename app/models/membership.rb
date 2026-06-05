class Membership < ApplicationRecord
  belongs_to :player
  belongs_to :pool
  validates :pool_id, uniqueness: { scope: :player_id }
end
