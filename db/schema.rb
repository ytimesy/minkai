# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_14_032000) do
  create_table "contributions", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name"
    t.string "role"
    t.text "body"
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_contributions_on_project_id"
  end

  create_table "development_stages", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "phase"
    t.text "image_description"
    t.text "model_description"
    t.text "blueprint_notes"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_development_stages_on_project_id"
  end

  create_table "project_artifacts", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "title"
    t.string "kind"
    t.string "url"
    t.text "notes"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_artifacts_on_project_id"
  end

  create_table "project_parts", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "category"
    t.string "name"
    t.text "purpose"
    t.string "quantity"
    t.text "candidate"
    t.string "estimated_price"
    t.text "source_note"
    t.text "alternative"
    t.text "note"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_parts_on_project_id"
  end

  create_table "project_risks", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "hazard"
    t.text "accident"
    t.text "cause"
    t.string "severity"
    t.string "likelihood"
    t.string "level"
    t.text "mitigation"
    t.text "test_method"
    t.text "residual_issue"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_risks_on_project_id"
  end

  create_table "project_roles", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_roles_on_project_id"
  end

  create_table "project_section_details", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "section", null: false
    t.string "subsection"
    t.string "title", null: false
    t.string "kind"
    t.text "body"
    t.string "status"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "section", "subsection"], name: "index_project_section_details_on_area"
    t.index ["project_id"], name: "index_project_section_details_on_project_id"
  end

  create_table "project_tasks", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "title"
    t.string "related_area"
    t.string "assignee"
    t.string "status"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_tasks_on_project_id"
  end

  create_table "project_test_items", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "title"
    t.text "success_relation"
    t.text "test_method"
    t.text "acceptance_criteria"
    t.text "result"
    t.string "evidence_url"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_test_items_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.string "category"
    t.text "summary"
    t.text "problem"
    t.text "target_users"
    t.text "success_metric"
    t.string "status"
    t.string "participation_needs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "specifications"
    t.text "features"
    t.text "intended_uses"
    t.text "scope_limits"
    t.text "system_architecture"
    t.text "mechanical_design"
    t.text "electrical_design"
    t.text "software_design"
    t.text "safety_design"
    t.text "manufacturing_steps"
    t.text "test_plan"
    t.text "development_log"
    t.text "bill_of_materials"
    t.text "next_prototype"
    t.text "basic_design"
    t.text "detail_design"
    t.text "data_transition_design"
  end

  add_foreign_key "contributions", "projects"
  add_foreign_key "development_stages", "projects"
  add_foreign_key "project_artifacts", "projects"
  add_foreign_key "project_parts", "projects"
  add_foreign_key "project_risks", "projects"
  add_foreign_key "project_roles", "projects"
  add_foreign_key "project_section_details", "projects"
  add_foreign_key "project_tasks", "projects"
  add_foreign_key "project_test_items", "projects"
end
