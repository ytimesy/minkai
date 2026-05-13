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

  def traceability_rows
    project_tasks.each_with_index.filter_map do |task, index|
      ids = {
        requirement: task.related_requirement_ids.first,
        part: task.related_part_ids.first,
        safety: task.related_safety_ids.first,
        test: task.related_test_ids.first,
        task: format("TASK-%03d", index + 1)
      }
      next if ids.values_at(:requirement, :part, :safety, :test).all?(&:blank?)

      ids.merge(title: task.title, status: task.status)
    end
  end

  def role_cards
    records = project_roles.to_a
    return records.map { |role| { name: role.name, description: role.description, status: role.status } } if records.any?

    [
      { name: "機械設計", description: "フレーム、構造、取り付け、重心、保守性を確認する。", status: "募集中" },
      { name: "電気設計", description: "電源、配線、ドライバ、非常停止、保護回路を確認する。", status: "募集中" },
      { name: "ソフトウェア", description: "入力、制御、安全停止、ログ、親プロジェクト連携を整理する。", status: "募集中" },
      { name: "安全レビュー", description: "危険源、停止条件、試験項目、残課題を確認する。", status: "募集中" },
      { name: "試作協力", description: "部品調達、組み立て、試験、写真・結果記録を行う。", status: "募集中" }
    ]
  end

  def stage_label
    return "部品開発" if component_project?

    food? ? "レシピ" : "設計図"
  end

  def stage_description(stage, field)
    if component_project? && source_bom_item.present?
      component_stage_description(stage.phase, field)
    else
      stage.public_send(field)
    end
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

  def component_stage_description(phase, field)
    if source_bom_item.name.to_s.match?(/モーター|駆動/)
      motor_component_stage_description(phase, field)
    else
      general_component_stage_description(phase, field)
    end
  end

  def motor_component_stage_description(phase, field)
    descriptions = {
      "初期" => {
        image_description: "必要トルク、速度、積載条件、電源条件を整理する。",
        model_description: "積載重量、車輪径、目標速度、電圧、連続動作時間の前提を表にする。",
        blueprint_notes: "親要求、BOM、試験条件へつながる駆動ユニット仕様を定義する。"
      },
      "中期" => {
        image_description: "候補モーター、モータードライバ、車輪径、ギア比を比較する。",
        model_description: "低速ギヤードモーター、ドライバ容量、減速比、車輪径、発熱条件を比較表にする。",
        blueprint_notes: "配線、固定方法、制御パラメータ、代替案を設計メモへ落とす。"
      },
      "後期" => {
        image_description: "実機で低速走行、発熱、積載、停止距離を試験する。",
        model_description: "試作台車に搭載し、負荷、速度、発熱、非常停止時の挙動を確認する。",
        blueprint_notes: "合格基準、測定値、失敗条件、改善点を試験結果へ反映する。"
      },
      "完成" => {
        image_description: "採用部品、配線、制御パラメータ、試験結果を親BOMへ反映する。",
        model_description: "採用モーター、ドライバ、車輪、ギア比、制御値を確定した駆動ユニット。",
        blueprint_notes: "親BOMの候補品、概算価格、調達方針、状態、注意点を更新する。"
      }
    }
    descriptions.fetch(phase).fetch(field)
  end

  def general_component_stage_description(phase, field)
    descriptions = {
      "初期" => {
        image_description: "親プロジェクトで必要な役割、関連要求、関連試験、制約を整理する。",
        model_description: "候補案、調達方針、Make or Buy判断、比較観点を表にする。",
        blueprint_notes: "親BOMへ戻す項目と、未検証リスクを明確にする。"
      },
      "中期" => {
        image_description: "候補品、接続仕様、取り付け条件、代替案を比較する。",
        model_description: "価格、入手性、実装難易度、安全性、保守性の比較表を作る。",
        blueprint_notes: "配線、固定、入力・出力、親プロジェクトとの連携仕様を整理する。"
      },
      "後期" => {
        image_description: "試作に組み込み、関連試験と安全レビューを実施する。",
        model_description: "親プロジェクトの試験条件で検証した候補モジュール。",
        blueprint_notes: "試験結果、残課題、採用判断を記録する。"
      },
      "完成" => {
        image_description: "採用候補、価格、調達方針、注意点を親BOMへ反映する。",
        model_description: "親プロジェクトで使える状態に整理された部品・モジュール。",
        blueprint_notes: "親BOM、関連要求、関連試験、成果物へ反映する。"
      }
    }
    descriptions.fetch(phase).fetch(field)
  end

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
