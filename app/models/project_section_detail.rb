class ProjectSectionDetail < ApplicationRecord
  KINDS = %w[設計メモ 仕様詳細 図面メモ データ設計 部品検討 リスク対策 試験設計 製造メモ レビュー 課題].freeze
  STATUSES = %w[下書き 検討中 レビュー待ち 確定 保留].freeze

  belongs_to :project

  validates :section, :title, :body, presence: true
  validates :section, inclusion: { in: Project::WORKSPACE_SECTIONS.keys }
  validates :subsection, inclusion: { in: Project::DESIGN_SECTIONS.keys }, allow_blank: true
  validates :kind, inclusion: { in: KINDS }
  validates :status, inclusion: { in: STATUSES }

  before_validation :set_defaults

  scope :ordered, -> { order(Arel.sql("COALESCE(position, 999999) ASC"), created_at: :asc) }

  def area_label
    base = project.section_label(section)
    detail = subsection.present? ? project.design_section_label(subsection) : nil
    detail.present? ? "#{base} / #{detail}" : base
  end

  private

  def set_defaults
    self.kind = "設計メモ" if kind.blank?
    self.status = "下書き" if status.blank?
  end
end
