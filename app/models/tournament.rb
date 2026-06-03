class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy
  has_many :teams, dependent: :destroy
  validates :name, presence: true
end
