class CreateProjectRisks < ActiveRecord::Migration[7.2]
  def change
    create_table :project_risks do |t|
      t.references :project, null: false, foreign_key: true
      t.string :hazard
      t.text :accident
      t.text :cause
      t.string :severity
      t.string :likelihood
      t.string :level
      t.text :mitigation
      t.text :test_method
      t.text :residual_issue
      t.string :status

      t.timestamps
    end
  end
end
