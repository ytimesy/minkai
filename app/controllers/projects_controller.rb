class ProjectsController < ApplicationController
  before_action :require_admin!, only: %i[edit update]
  before_action :set_project, only: %i[show section edit update]

  def index
    @projects = Project.recent
    @project = Project.new
  end

  def show
    prepare_workspace("overview")
  end

  def section
    unless Project::WORKSPACE_SECTIONS.key?(params[:section])
      redirect_to @project, alert: "指定されたページはありません。"
      return
    end

    if params[:section] == "blueprints" && params[:design_section].present? && !Project::DESIGN_SECTIONS.key?(params[:design_section])
      redirect_to project_section_path(@project, section: "blueprints"), alert: "指定された設計ページはありません。"
      return
    end

    prepare_workspace(params[:section], params[:design_section])
    render :show
  end

  def edit
    @project.ensure_development_stages
  end

  def update
    @project.ensure_development_stages

    if @project.update(project_params)
      redirect_to @project, notice: "開発内容を更新しました。"
    else
      @project.ensure_development_stages
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "開発テーマを公開しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_project
    @project = Project.find(params[:id] || params[:project_id])
  end

  def prepare_workspace(section, design_section = nil)
    @section = section
    @section_label = Project::WORKSPACE_SECTIONS.fetch(section)
    @design_section = section == "blueprints" ? (design_section.presence || "overview") : nil
    @design_section_label = Project::DESIGN_SECTIONS.fetch(@design_section, nil)
    @project.ensure_development_stages
    @contribution = @project.contributions.build
    @project_section_detail = @project.project_section_details.build(section: section, subsection: @design_section)
    @section_details = @project.details_for(section, @design_section)
  end

  def project_params
    params.require(:project).permit(
      :title,
      :category,
      :summary,
      :problem,
      :target_users,
      :success_metric,
      :status,
      :participation_needs,
      :specifications,
      :features,
      :intended_uses,
      :scope_limits,
      :system_architecture,
      :basic_design,
      :detail_design,
      :data_transition_design,
      :mechanical_design,
      :electrical_design,
      :software_design,
      :safety_design,
      :manufacturing_steps,
      :test_plan,
      :development_log,
      :bill_of_materials,
      :next_prototype,
      development_stages_attributes: %i[
        id
        phase
        image_description
        model_description
        blueprint_notes
        position
      ]
    )
  end

  def require_admin!
    return if Rails.env.local? && ENV["MINKAI_ADMIN_PASSWORD"].blank?

    authenticate_or_request_with_http_basic("みんなの開発村 管理") do |_user, password|
      expected = ENV.fetch("MINKAI_ADMIN_PASSWORD", "")
      expected.present? && ActiveSupport::SecurityUtils.secure_compare(password, expected)
    end
  end
end
