class ProjectTestItem < ApplicationRecord
  belongs_to :project

  validates :title, :status, presence: true
end
