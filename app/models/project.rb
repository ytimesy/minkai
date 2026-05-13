class Project < ApplicationRecord
  CATEGORIES = %w[機械 ロボット 政策 Webサイト 料理 研究 その他].freeze
  STATUSES = %w[構想 設計中 試作中 検証中 公開中].freeze

  has_many :contributions, dependent: :destroy

  validates :title, :category, :summary, :problem, :target_users, :success_metric, presence: true

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_defaults

  private

  def set_defaults
    self.status = "構想" if status.blank?
    self.participation_needs = "設計レビュー・調査・試作" if participation_needs.blank?
  end
end
