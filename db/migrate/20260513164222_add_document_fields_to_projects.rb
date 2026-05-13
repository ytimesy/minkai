class AddDocumentFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :intended_uses, :text
    add_column :projects, :scope_limits, :text
    add_column :projects, :system_architecture, :text
    add_column :projects, :mechanical_design, :text
    add_column :projects, :electrical_design, :text
    add_column :projects, :software_design, :text
    add_column :projects, :safety_design, :text
    add_column :projects, :manufacturing_steps, :text
    add_column :projects, :test_plan, :text
    add_column :projects, :development_log, :text
    add_column :projects, :bill_of_materials, :text
    add_column :projects, :next_prototype, :text
  end
end
