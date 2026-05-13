class Contribution < ApplicationRecord
  KINDS = %w[アイデア 設計レビュー 調査 部品候補 試作ログ テスト結果 安全指摘 改善提案 協力希望].freeze

  belongs_to :project

  validates :name, :body, :kind, presence: true

  before_validation :set_defaults

  private

  def set_defaults
    self.kind = "アイデア" if kind.blank?
    self.role = "参加者" if role.blank?
  end
end
