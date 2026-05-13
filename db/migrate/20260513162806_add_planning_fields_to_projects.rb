class AddPlanningFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :specifications, :text
    add_column :projects, :features, :text
  end
end
