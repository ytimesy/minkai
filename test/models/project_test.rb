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

  test "maturity score is average of breakdown" do
    project = projects(:one)
    expected = (project.maturity_breakdown.values.sum / project.maturity_breakdown.size.to_f).round

    assert_equal expected, project.maturity_score
    assert_operator project.maturity_score, :<, 100
  end

  test "builds requirement ids from success metric" do
    project = projects(:one)

    assert_equal "REQ-001", project.requirement_items.first[:id]
    assert_equal "20kgを安全に運べる", project.requirement_items.first[:body]
  end

  test "task extracts related traceability ids" do
    task = projects(:one).project_tasks.build(
      title: "関連ID抽出",
      status: "未着手",
      related_area: "REQ-003 / BOM-004 / SAFE-001 / TEST-003"
    )

    assert_equal ["REQ-003"], task.related_requirement_ids
    assert_equal ["BOM-004"], task.related_part_ids
    assert_equal ["SAFE-001"], task.related_safety_ids
    assert_equal ["TEST-003"], task.related_test_ids
  end
end
