class CreateProjectTestItems < ActiveRecord::Migration[7.2]
  def change
    create_table :project_test_items do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title
      t.text :success_relation
      t.text :test_method
      t.text :acceptance_criteria
      t.text :result
      t.string :evidence_url
      t.string :status

      t.timestamps
    end
  end
end
