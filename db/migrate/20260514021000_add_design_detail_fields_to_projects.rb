class AddDesignDetailFieldsToProjects < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :basic_design, :text
    add_column :projects, :detail_design, :text
    add_column :projects, :data_transition_design, :text
  end
end
