class ProjectPart < ApplicationRecord
  belongs_to :project

  validates :category, :name, presence: true
end
