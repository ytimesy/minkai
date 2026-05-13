class CreateDevelopmentStages < ActiveRecord::Migration[7.2]
  def change
    create_table :development_stages do |t|
      t.references :project, null: false, foreign_key: true
      t.string :phase
      t.text :image_description
      t.text :model_description
      t.text :blueprint_notes
      t.integer :position

      t.timestamps
    end
  end
end
