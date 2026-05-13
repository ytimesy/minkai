class Project < ApplicationRecord
  CATEGORIES = %w[機械 ロボット 政策 Webサイト 料理 研究 その他].freeze
  STATUSES = %w[構想 設計中 試作中 検証中 公開中].freeze

  has_many :contributions, dependent: :destroy
  has_many :development_stages, -> { order(:position) }, dependent: :destroy
  accepts_nested_attributes_for :development_stages

  validates :title, :category, :summary, :problem, :target_users, :success_metric, presence: true

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_defaults
  after_initialize :build_default_development_stages, if: :new_record?

  def ensure_development_stages
    build_default_development_stages
  end

  private

  def set_defaults
    self.status = "構想" if status.blank?
    self.participation_needs = "設計レビュー・調査・試作" if participation_needs.blank?
    self.specifications = "材料・寸法・性能・予算・安全条件を整理する" if specifications.blank?
    self.features = "利用者が最初に必要とする機能から優先順位を決める" if features.blank?
  end

  def build_default_development_stages
    DevelopmentStage::PHASES.each_with_index do |phase, index|
      next if development_stages.any? { |stage| stage.phase == phase }

      development_stages.build(
        phase: phase,
        position: index + 1,
        image_description: DevelopmentStage.default_image_description(phase),
        model_description: DevelopmentStage.default_model_description(phase),
        blueprint_notes: DevelopmentStage.default_blueprint_notes(phase)
      )
    end
  end
end
