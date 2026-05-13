class CreateProjectParts < ActiveRecord::Migration[7.2]
  def change
    create_table :project_parts do |t|
      t.references :project, null: false, foreign_key: true
      t.string :category
      t.string :name
      t.text :purpose
      t.string :quantity
      t.text :candidate
      t.string :estimated_price
      t.text :source_note
      t.text :alternative
      t.text :note
      t.string :status

      t.timestamps
    end
  end
end
