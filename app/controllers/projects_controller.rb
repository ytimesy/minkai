class ProjectsController < ApplicationController
  before_action :require_admin!, only: %i[edit update]

  def index
    @projects = Project.recent
    @project = Project.new
  end

  def show
    @project = Project.find(params[:id])
    @project.ensure_development_stages
    @contribution = @project.contributions.build
  end

  def new
    @project = Project.new
  end

  def edit
    @project = Project.find(params[:id])
    @project.ensure_development_stages
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "開発テーマを公開しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @project = Project.find(params[:id])
    @project.ensure_development_stages

    if @project.update(project_params)
      redirect_to @project, notice: "開発内容を更新しました。"
    else
      @project.ensure_development_stages
      render :edit, status: :unprocessable_entity
    end
  end

  private

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
