require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get show" do
    get project_url(projects(:one))
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: {
        project: {
          title: "自治体向け申請サイト",
          category: "Webサイト",
          summary: "申請を迷わず進められるサイト",
          problem: "制度ごとに入口が分かれている",
          target_users: "住民と自治体職員",
          success_metric: "必要な申請に3分以内で到達できる",
          status: "構想",
          participation_needs: "UI設計"
        }
      }
    end

    assert_redirected_to project_url(Project.last)
  end
end
