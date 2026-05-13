class CreateProjectTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :project_tasks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :related_area
      t.string :assignee
      t.string :status
      t.text :description

      t.timestamps
    end
  end
end
