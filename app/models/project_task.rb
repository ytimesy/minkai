class ProjectTask < ApplicationRecord
  belongs_to :project

  STATUSES = %w[未着手 担当者募集中 作業中 レビュー待ち 完了 保留].freeze

  validates :title, :status, presence: true
end
