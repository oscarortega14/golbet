class Tournament < ApplicationRecord
  has_many :matches, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :pools, dependent: :destroy
  belongs_to :champion_team, class_name: "Team", optional: true

  validates :name, presence: true

  def started?
    earliest = matches.minimum(:kickoff_at)
    earliest.present? && earliest <= Time.current
  end
end
