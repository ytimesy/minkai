require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "uses food-specific workspace labels" do
    project = projects(:two)

    assert_equal "材料", project.section_label("bom")
    assert_equal "レシピ", project.section_label("blueprints")
    assert_equal "詳細レシピ", project.design_section_label("detail")
    assert_equal "細かいレシピ開発", project.detail_workbench_label
  end

  test "keeps robot workspace labels" do
    project = projects(:one)

    assert_equal "部品表", project.section_label("bom")
    assert_equal "設計", project.section_label("blueprints")
    assert_equal "詳細設計", project.design_section_label("detail")
    assert_equal "細かい設計開発", project.detail_workbench_label
  end
end
