class CreateProjectSectionDetails < ActiveRecord::Migration[7.2]
  def change
    create_table :project_section_details do |t|
      t.references :project, null: false, foreign_key: true
      t.string :section, null: false
      t.string :subsection
      t.string :title, null: false
      t.string :kind
      t.text :body
      t.string :status
      t.integer :position

      t.timestamps
    end

    add_index :project_section_details, %i[project_id section subsection], name: "index_project_section_details_on_area"
  end
end
