class CreateContributions < ActiveRecord::Migration[7.2]
  def change
    create_table :contributions do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.text :body
      t.string :kind

      t.timestamps
    end
  end
end
