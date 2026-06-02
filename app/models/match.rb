class Match < ApplicationRecord
  belongs_to :tournament
  has_many :predictions, dependent: :destroy

  STATUSES = %w[scheduled finished].freeze

  validates :home_team, :away_team, presence: true
  validates :kickoff_at, presence: true
  validates :status, inclusion: { in: STATUSES }

  after_initialize { self.status ||= "scheduled" }

  def finished?
    status == "finished"
  end

  def locked?
    kickoff_at.present? && Time.current >= kickoff_at
  end
end
