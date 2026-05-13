class Project < ApplicationRecord
  CATEGORIES = %w[機械 ロボット 政策 Webサイト 料理 研究 その他].freeze
  STATUSES = %w[構想 設計中 試作中 検証中 公開中].freeze
  PROJECT_TYPES = %w[main_project component_project module_project test_project].freeze
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

  CATEGORY_SECTION_LABELS = {
    "料理" => {
      "requirements" => "レシピ要件",
      "blueprints" => "レシピ",
      "bom" => "材料",
      "software" => "記録・共有",
      "safety" => "衛生・アレルギー",
      "manufacturing" => "調理工程",
      "tests" => "再現テスト",
      "tasks" => "試作タスク",
      "artifacts" => "完成レシピ"
    },
    "政策" => {
      "requirements" => "政策要件",
      "blueprints" => "制度案",
      "bom" => "予算・資源",
      "software" => "運用設計",
      "safety" => "リスク",
      "manufacturing" => "実証計画",
      "tests" => "効果検証",
      "artifacts" => "政策パッケージ"
    },
    "Webサイト" => {
      "requirements" => "要件定義",
      "blueprints" => "画面・導線",
      "bom" => "機能・DB",
      "software" => "実装設計",
      "safety" => "運用リスク",
      "manufacturing" => "開発手順",
      "tests" => "検証項目",
      "artifacts" => "リリース物"
    }
  }.freeze

  CATEGORY_DESIGN_LABELS = {
    "料理" => {
      "overview" => "レシピトップ",
      "basic" => "基本レシピ",
      "detail" => "詳細レシピ",
      "data-transition" => "調理・保存の流れ"
    },
    "政策" => {
      "overview" => "制度案トップ",
      "basic" => "基本制度案",
      "detail" => "詳細制度案",
      "data-transition" => "手続き・運用の流れ"
    },
    "Webサイト" => {
      "overview" => "画面・導線トップ",
      "basic" => "基本画面設計",
      "detail" => "詳細画面設計",
      "data-transition" => "データ遷移設計"
    }
  }.freeze

  has_many :contributions, dependent: :destroy
  has_many :development_stages, -> { order(:position) }, dependent: :destroy
  has_many :project_parts, dependent: :destroy
  has_many :project_risks, dependent: :destroy
  has_many :project_test_items, dependent: :destroy
  has_many :project_tasks, dependent: :destroy
  has_many :project_artifacts, dependent: :destroy
  has_many :project_roles, dependent: :destroy
  has_many :project_section_details, dependent: :destroy
  belongs_to :parent_project, class_name: "Project", optional: true
  belongs_to :source_bom_item, class_name: "ProjectPart", optional: true
  has_many :child_projects, class_name: "Project", foreign_key: :parent_project_id, dependent: :nullify, inverse_of: :parent_project
  accepts_nested_attributes_for :development_stages

  validates :title, :category, :summary, :problem, :target_users, :success_metric, presence: true
  validates :project_type, inclusion: { in: PROJECT_TYPES }

  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_defaults
  after_initialize :build_default_development_stages, if: :new_record?

  def ensure_development_stages
    build_default_development_stages
  end

  def maturity_score
    values = maturity_breakdown.values
    return 0 if values.empty?

    (values.sum / values.size.to_f).round
  end

  def maturity_breakdown
    {
      "要求仕様" => specifications.present? ? 70 : 20,
      "設計" => [[basic_design, detail_design, data_transition_design, mechanical_design, electrical_design, software_design].count(&:present?) * 16, 100].min,
      "部品表" => project_parts.any? ? 80 : (bill_of_materials.present? ? 40 : 10),
      "安全" => project_risks.any? ? 85 : (safety_design.present? ? 45 : 10),
      "試験" => project_test_items.any? ? 80 : (test_plan.present? ? 40 : 10),
      "参加・ログ" => [[(contributions.count + project_section_details.count) * 12, 45].min + (development_log.present? ? 35 : 0), 100].min
    }
  end

  def details_for(section, subsection = nil)
    scope = project_section_details.where(section: section)
    scope = if subsection.present?
              scope.where(subsection: subsection)
            else
              scope.where(subsection: [nil, ""])
            end
    scope.ordered
  end

  def requirement_items
    lines = success_metric.to_s.lines.map(&:strip).reject(&:blank?)

    lines.each_with_index.map do |line, index|
      cleaned = line.sub(/\A[・\-\u25a1□\s]+/, "")
      match = cleaned.match(/\A(?<id>REQ-\d{3})[:：\s]*(?<body>.+)\z/)
      {
        id: match ? match[:id] : format("REQ-%03d", index + 1),
        body: match ? match[:body] : cleaned
      }
    end
  end

  def next_tasks(limit = 3)
    project_tasks.where.not(status: "完了").limit(limit)
  end

  def workspace_sections
    if component_project?
      return {
        "overview" => "概要",
        "requirements" => "要求",
        "bom" => "候補案",
        "blueprints" => "設計",
        "software" => "接続仕様",
        "tests" => "試験",
        "safety" => "リスク",
        "tasks" => "タスク",
        "artifacts" => "親プロジェクトへの反映"
      }
    end

    WORKSPACE_SECTIONS.each_with_object({}) do |(key, _label), labels|
      labels[key] = section_label(key)
    end
  end

  def section_label(section)
    CATEGORY_SECTION_LABELS.dig(category, section) || WORKSPACE_SECTIONS.fetch(section)
  end

  def design_sections
    DESIGN_SECTIONS.each_with_object({}) do |(key, _label), labels|
      labels[key] = design_section_label(key)
    end
  end

  def design_section_label(section)
    CATEGORY_DESIGN_LABELS.dig(category, section) || DESIGN_SECTIONS.fetch(section)
  end

  def food?
    category == "料理"
  end

  def document_word
    food? ? "レシピ" : "設計"
  end

  def detail_workbench_label
    food? ? "細かいレシピ開発" : "細かい設計開発"
  end

  def component_project?
    project_type == "component_project"
  end

  def safety_review_required?
    source_bom_item&.safety_critical?
  end

  private

  def set_defaults
    self.project_type = "main_project" if project_type.blank?
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
