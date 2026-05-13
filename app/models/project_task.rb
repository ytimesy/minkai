class ProjectTask < ApplicationRecord
  belongs_to :project

  STATUSES = %w[未着手 担当者募集中 作業中 レビュー待ち 完了 保留].freeze

  validates :title, :status, presence: true

  def related_requirement_ids
    related_area.to_s.scan(/REQ-\d{3}/).uniq
  end

  def related_part_ids
    related_area.to_s.scan(/(?:BOM|PART)-\d{3}/).uniq
  end

  def related_safety_ids
    related_area.to_s.scan(/SAFE-\d{3}/).uniq
  end

  def related_test_ids
    related_area.to_s.scan(/TEST-\d{3}/).uniq
  end
end
