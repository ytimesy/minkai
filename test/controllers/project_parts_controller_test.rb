require "test_helper"

class ProjectPartsControllerTest < ActionDispatch::IntegrationTest
  test "should show component confirmation" do
    project = projects(:one)
    part = project_parts(:one)
    part.update!(procurement_policy: "researching", requirement_ids: "REQ-003", test_ids: "TEST-003")

    get new_component_project_part_url(project, part)

    assert_response :success
    assert_select "h1", text: part.component_title
    assert_select "p", text: /#{part.tracking_id}/
  end

  test "should create component project from part" do
    project = projects(:one)
    part = project_parts(:one)
    part.update!(name: "距離センサー", purpose: "障害物検知", procurement_policy: "researching", requirement_ids: "REQ-003", test_ids: "TEST-003")

    assert_difference("Project.count") do
      post component_project_part_url(project, part)
    end

    part.reload
    assert part.child_project.present?
    assert_equal "component_project", part.child_project.project_type
    assert_equal project, part.child_project.parent_project
    assert_equal "開発テーマ化済み", part.development_status
    assert_redirected_to project_url(part.child_project)
  end

  test "should not duplicate component project" do
    project = projects(:one)
    part = project_parts(:one)
    part.update!(procurement_policy: "researching")

    post component_project_part_url(project, part)
    child = part.reload.child_project

    assert_no_difference("Project.count") do
      post component_project_part_url(project, part)
    end

    assert_redirected_to project_url(child)
  end

  test "should sync child project fields back to parent bom" do
    project = projects(:one)
    part = project_parts(:one)
    part.update!(name: "左右モーター", purpose: "移動用", procurement_policy: "researching", requirement_ids: "REQ-006", test_ids: "TEST-006")

    post component_project_part_url(project, part)
    child = part.reload.child_project
    child.update!(bill_of_materials: "候補A")

    post sync_from_child_project_part_url(project, part), params: {
      project_part: {
        candidate: "低速ギヤードモーター案A",
        estimated_price: "4,000円",
        procurement_policy: "buy",
        status: "候補確定",
        note: "発熱試験が必要"
      }
    }

    part.reload
    assert_equal "低速ギヤードモーター案A", part.candidate
    assert_equal "4,000円", part.estimated_price
    assert_equal "buy", part.procurement_policy
    assert_equal "候補確定", part.status
    assert_equal "発熱試験が必要", part.note
    assert_equal "親BOM反映済み", part.development_status
    assert_redirected_to project_section_url(project, section: "bom")
  end
end
