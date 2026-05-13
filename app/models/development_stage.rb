class DevelopmentStage < ApplicationRecord
  PHASES = %w[初期 中期 後期 完成].freeze

  belongs_to :project

  validates :phase, :position, presence: true

  scope :ordered, -> { order(:position) }

  def self.default_image_description(phase)
    {
      "初期" => "粗い構想図。主要部品、利用場面、対象者の動きが一目で分かる状態。",
      "中期" => "試作モデル。形状、寸法感、操作部、材料の候補が見える状態。",
      "後期" => "検証用モデル。実利用に近い配置、耐久性、安全性、導線を確認できる状態。",
      "完成" => "完成イメージ。実際の利用環境に置かれ、利用者が成果を得ている状態。"
    }.fetch(phase)
  end

  def self.default_model_description(phase)
    {
      "初期" => "紙スケッチ、簡易ワイヤーフレーム、段ボール模型、手順メモ。",
      "中期" => "寸法入りモック、クリック可能な画面、試作レシピ、制度フロー案。",
      "後期" => "実寸に近い試作品、運用テスト版、評価用プロトタイプ。",
      "完成" => "公開版、量産前モデル、提供可能な完成パッケージ。"
    }.fetch(phase)
  end

  def self.default_blueprint_notes(phase)
    {
      "初期" => "構成要素と前提条件を分解する。",
      "中期" => "寸法、材料、画面遷移、業務手順、調理工程を具体化する。",
      "後期" => "検証項目、リスク、改善履歴、合格基準を設計図に反映する。",
      "完成" => "製造・運用・保守・公開に必要な最終図面と手順を整える。"
    }.fetch(phase)
  end
end
