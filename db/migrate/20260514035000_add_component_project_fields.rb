class AddComponentProjectFields < ActiveRecord::Migration[7.2]
  def change
    add_reference :projects, :parent_project, foreign_key: { to_table: :projects }
    add_reference :projects, :source_bom_item, foreign_key: { to_table: :project_parts }
    add_column :projects, :project_type, :string, default: "main_project", null: false

    add_column :project_parts, :procurement_policy, :string, default: "undecided", null: false
    add_column :project_parts, :requirement_ids, :string
    add_column :project_parts, :test_ids, :string
    add_reference :project_parts, :child_project, foreign_key: { to_table: :projects }
    add_column :project_parts, :development_status, :string, default: "未テーマ化", null: false
  end
end
