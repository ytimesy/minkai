class ProjectArtifact < ApplicationRecord
  belongs_to :project

  validates :title, :kind, presence: true
end
