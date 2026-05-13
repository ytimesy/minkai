require "test_helper"

class ContributionsControllerTest < ActionDispatch::IntegrationTest
  test "should create contribution" do
    project = projects(:one)

    assert_difference("Contribution.count") do
      post project_contributions_url(project), params: {
        contribution: {
          name: "参加者C",
          role: "政策調査",
          kind: "調査",
          body: "関連制度を調べます。"
        }
      }
    end

    assert_redirected_to project_url(project)
  end
end
