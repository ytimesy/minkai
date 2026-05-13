class ProjectsController < ApplicationController
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
end
