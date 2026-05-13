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

  test "should get workspace sections" do
    project = projects(:one)

    Project::WORKSPACE_SECTIONS.each_key do |section|
      next if section == "overview"

      get project_section_url(project, section: section)
      assert_response :success
    end
  end

  test "section pages show detailed design workbench" do
    project = projects(:one)

    get project_section_url(project, section: "requirements")

    assert_response :success
    assert_select "h2", text: "細かい設計開発"
    assert_select "summary", text: "このセクションに追加"
    assert_select "h3", text: project_section_details(:one).title
  end

  test "food project uses recipe labels" do
    project = projects(:two)

    get project_section_url(project, section: "bom")
    assert_response :success
    assert_select "h2", text: "材料"
    assert_select "h2", text: "細かいレシピ開発"

    get project_design_section_url(project, section: "blueprints", design_section: "detail")
    assert_response :success
    assert_select "h2", text: "詳細レシピ"
    assert_select "h3", text: "材料"
  end

  test "should get design subsections" do
    project = projects(:one)

    Project::DESIGN_SECTIONS.each_key do |design_section|
      next if design_section == "overview"

      get project_design_section_url(project, section: "blueprints", design_section: design_section)
      assert_response :success
    end
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(projects(:one))
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
          participation_needs: "UI設計",
          specifications: "スマートフォン対応、3分以内に申請到達",
          features: "申請検索、必要書類チェック、進捗確認"
        }
      }
    end

    assert_redirected_to project_url(Project.last)
    assert_equal 4, Project.last.development_stages.count
  end

  test "should update project planning fields" do
    project = projects(:one)

    patch project_url(project), params: {
      project: {
        title: project.title,
        category: project.category,
        summary: project.summary,
        problem: project.problem,
        target_users: project.target_users,
        success_metric: project.success_metric,
        status: "検証中",
        participation_needs: project.participation_needs,
        specifications: "耐荷重30kgに更新",
        features: "遠隔停止を追加",
        intended_uses: "教材と施設内案内",
        scope_limits: "人を乗せない",
        system_architecture: "入力から安全停止まで",
        basic_design: "MVP範囲と全体構成",
        detail_design: "部品配置と例外処理",
        data_transition_design: "仕様から試験結果までの状態遷移",
        mechanical_design: "二輪差動",
        electrical_design: "低電圧構成",
        software_design: "Python制御",
        safety_design: "非常停止と障害物停止",
        manufacturing_steps: "フレームを組む",
        test_plan: "停止試験",
        development_log: "仕様更新",
        bill_of_materials: "モーター / 駆動 / 2",
        next_prototype: "小型台車",
        development_stages_attributes: {
          "0" => {
            id: development_stages(:one).id,
            phase: "初期",
            position: 1,
            image_description: "更新した構想図",
            model_description: "更新した紙模型",
            blueprint_notes: "更新した設計図"
          }
        }
      }
    }

    assert_redirected_to project_url(project)
    project.reload
    assert_equal "耐荷重30kgに更新", project.specifications
    assert_equal "MVP範囲と全体構成", project.basic_design
    assert_equal "部品配置と例外処理", project.detail_design
    assert_equal "仕様から試験結果までの状態遷移", project.data_transition_design
    assert_equal "非常停止と障害物停止", project.safety_design
    assert_equal "モーター / 駆動 / 2", project.bill_of_materials
    assert_equal "更新した構想図", development_stages(:one).reload.image_description
  end
end
