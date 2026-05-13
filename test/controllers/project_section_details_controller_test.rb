require "test_helper"

class ProjectSectionDetailsControllerTest < ActionDispatch::IntegrationTest
  test "should create section detail" do
    project = projects(:one)

    assert_difference("ProjectSectionDetail.count") do
      post project_section_details_url(project), params: {
        project_section_detail: {
          section: "requirements",
          title: "成功条件の分解",
          kind: "仕様詳細",
          body: "成功条件を検証可能な項目へ分解する。",
          status: "検討中"
        }
      }
    end

    assert_redirected_to project_section_url(project, section: "requirements")
  end

  test "should create design subsection detail" do
    project = projects(:one)

    assert_difference("ProjectSectionDetail.count") do
      post project_section_details_url(project), params: {
        project_section_detail: {
          section: "blueprints",
          subsection: "detail",
          title: "モーター配置",
          kind: "図面メモ",
          body: "左右モーターの固定位置と保守スペースを決める。",
          status: "下書き"
        }
      }
    end

    assert_redirected_to project_design_section_url(project, section: "blueprints", design_section: "detail")
  end
end
