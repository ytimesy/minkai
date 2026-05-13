class ProjectRisk < ApplicationRecord
  belongs_to :project

  validates :hazard, :level, presence: true
end
