class CreateProjectRoles < ActiveRecord::Migration[7.2]
  def change
    create_table :project_roles do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
