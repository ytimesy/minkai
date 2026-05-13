class Project < ApplicationRecord
  CATEGORIES = %w[機械 ロボット 政策 Webサイト 料理 研究 その他].freeze
  STATUSES = %w[構想 設計中 試作中 検証中 公開中].freeze
  WORKSPACE_SECTIONS = {
    "overview" => "概要",
    "requirements" => "要求仕様",
    "blueprints" => "設計",
    "bom" => "部品表",
    "software" => "ソフトウェア",
    "safety" => "安全設計",
    "manufacturing" => "製造手順",
    "tests" => "試験項目",
    "tasks" => "タスク",
    "log" => "開発ログ",
    "join" => "参加募集",
    "artifacts" => "成果物"
  }.freeze

  DESIGN_SECTIONS = {
    "overview" => "設計トップ",
    "basic" => "基本設計",
    "detail" => "詳細設計",
    "data-transition" => "データ遷移設計"
  }.freeze

  has_many :contributions, dependent: :destroy
  has_many :development_stages, -> { order(:position) }, dependent: :destroy
  has_many :project_parts, dependent: :destroy
  has_many :project_risks, dependent: :destroy
  has_many :project_test_items, dependent: :destroy
  has_many :project_tasks, dependent: :destroy
  has_many :project_artifacts, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  accepts_nested_attributes_for :development_stages

  validates :title, :category, :summary, :problem, :target_users, :success_metric, presence: true

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_defaults
  after_initialize :build_default_development_stages, if: :new_record?

  def ensure_development_stages
    build_default_development_stages
  end

  def maturity_score
    checks = [
      problem.present?,
      target_users.present?,
      success_metric.present?,
      specifications.present?,
      basic_design.present? || detail_design.present? || data_transition_design.present? || system_architecture.present? || mechanical_design.present? || electrical_design.present? || software_design.present?,
      project_parts.any? || bill_of_materials.present?,
      project_risks.any? || safety_design.present?,
      project_test_items.any? || test_plan.present?,
      contributions.any?,
      development_log.present?
    ]

    (checks.count(true) * 100 / checks.size.to_f).round
  end

  def maturity_breakdown
    {
      "要求仕様" => specifications.present? ? 70 : 20,
      "設計" => [[basic_design, detail_design, data_transition_design, mechanical_design, electrical_design, software_design].count(&:present?) * 16, 100].min,
      "部品表" => project_parts.any? ? 80 : (bill_of_materials.present? ? 40 : 10),
      "安全" => project_risks.any? ? 85 : (safety_design.present? ? 45 : 10),
      "試験" => project_test_items.any? ? 80 : (test_plan.present? ? 40 : 10),
      "参加・ログ" => [[contributions.count * 15, 45].min + (development_log.present? ? 35 : 0), 100].min
    }
  end

  private

  def set_defaults
    self.status = "構想" if status.blank?
    self.participation_needs = "設計レビュー・調査・試作" if participation_needs.blank?
    self.specifications = "材料・寸法・性能・予算・安全条件を整理する" if specifications.blank?
    self.features = "利用者が最初に必要とする機能から優先順位を決める" if features.blank?
    self.intended_uses = "想定用途を整理する" if intended_uses.blank?
    self.scope_limits = "MVPでやらないことを明記する" if scope_limits.blank?
    self.system_architecture = "入力、判断、制御、安全停止の流れを整理する" if system_architecture.blank?
    self.basic_design = "目的、利用者、MVP範囲、システム全体構成、主要な画面・機能・構造を整理する" if basic_design.blank?
    self.detail_design = "基本設計をもとに、画面、部品、制御、例外処理、運用手順を実装可能な粒度へ分解する" if detail_design.blank?
    self.data_transition_design = "入力データ、状態、成果物、レビュー、試験結果がどの順序で変化するかを整理する" if data_transition_design.blank?
    self.mechanical_design = "外形、駆動方式、重心、保守口を整理する" if mechanical_design.blank?
    self.electrical_design = "低電圧の試作構成、電源、非常停止、センサー配線を整理する" if electrical_design.blank?
    self.software_design = "入力層、理解層、判断層、制御層、安全層を整理する" if software_design.blank?
    self.safety_design = "速度制限、非常停止、障害物停止、禁止用途を整理する" if safety_design.blank?
    self.manufacturing_steps = "試作手順を段階的に整理する" if manufacturing_steps.blank?
    self.test_plan = "成功条件を試験項目へ変換する" if test_plan.blank?
    self.development_log = "開発履歴を時系列で記録する" if development_log.blank?
    self.bill_of_materials = "カテゴリ、部品名、用途、数量、候補、注意点を整理する" if bill_of_materials.blank?
    self.next_prototype = "次に作る試作と確認項目を整理する" if next_prototype.blank?
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
