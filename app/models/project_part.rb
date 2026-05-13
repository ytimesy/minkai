class ProjectPart < ApplicationRecord
  belongs_to :project

  validates :category, :name, presence: true

  def tracking_id
    index = project.project_parts.order(:id).pluck(:id).index(id).to_i + 1
    format("PART-%03d", index)
  end
end
