class ProjectPart < ApplicationRecord
  PROCUREMENT_POLICIES = {
    "buy" => "購入",
    "make" => "自作",
    "outsource" => "外注",
    "modify_existing" => "既製品改造",
    "researching" => "調査中",
    "undecided" => "未定",
    "alternative_review" => "代替検討"
  }.freeze

  DEVELOPABLE_POLICIES = %w[make outsource researching alternative_review modify_existing undecided].freeze
  GENERIC_KEYWORDS = %w[M3ネジ 汎用ブラケット 汎用ケーブル ネジ ケーブル ブラケット].freeze
  SAFETY_KEYWORDS = %w[非常停止 バッテリー モータードライバ 安全停止 障害物検知 距離センサー].freeze

  belongs_to :project
  belongs_to :child_project, class_name: "Project", optional: true

  validates :category, :name, presence: true
  validates :procurement_policy, inclusion: { in: PROCUREMENT_POLICIES.keys }, allow_blank: true

  def tracking_id
    index = project.project_parts.order(:id).pluck(:id).index(id).to_i + 1
    format("BOM-%03d", index)
  end

  def procurement_policy_label
    PROCUREMENT_POLICIES.fetch(procurement_policy.presence || "undecided")
  end

  def developable?
    valid_child_project.present? || (DEVELOPABLE_POLICIES.include?(procurement_policy) && !generic_part?)
  end

  def generic_part?
    GENERIC_KEYWORDS.any? { |word| name.to_s.include?(word) }
  end

  def safety_critical?
    SAFETY_KEYWORDS.any? { |word| name.to_s.include?(word) || purpose.to_s.include?(word) }
  end

  def component_title
    case name
    when /モーター/
      "低速高トルク駆動ユニット開発"
    when /非常停止/
      "非常停止インターフェース設計"
    when /距離センサー|障害物検知/
      "前方障害物検知モジュール開発"
    when /フレーム/
      "低重心フレーム設計"
    when /音声/
      "音声コマンド入力モジュール開発"
    else
      "#{name}モジュール開発"
    end
  end

  def valid_child_project
    child_project if child_project_id.present? && child_project&.persisted?
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def child_project_state
    return "未作成" unless valid_child_project
    return "親BOMへ反映済み" if development_status == "親BOM反映済み"
    return "候補確定" if status.to_s.include?("確定")
    return "候補調査中" if valid_child_project.status.to_s.include?("調査") || development_status.to_s.include?("調査")

    "子開発ページあり"
  end
end
