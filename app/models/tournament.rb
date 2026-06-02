class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy
  validates :name, presence: true
end
