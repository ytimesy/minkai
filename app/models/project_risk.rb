class ProjectRisk < ApplicationRecord
  belongs_to :project

  validates :hazard, :level, presence: true

  def tracking_id
    index = project.project_risks.order(:id).pluck(:id).index(id).to_i + 1
    format("SAFE-%03d", index)
  end
end
