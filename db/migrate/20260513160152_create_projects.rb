class CreateProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :category
      t.text :summary
      t.text :problem
      t.text :target_users
      t.text :success_metric
      t.string :status
      t.string :participation_needs

      t.timestamps
    end
  end
end
