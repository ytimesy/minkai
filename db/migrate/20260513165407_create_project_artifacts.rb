class CreateProjectArtifacts < ActiveRecord::Migration[7.2]
  def change
    create_table :project_artifacts do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.string :kind
      t.string :url
      t.text :notes
      t.string :status

      t.timestamps
    end
  end
end
