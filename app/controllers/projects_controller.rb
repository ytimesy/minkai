class ProjectsController < ApplicationController
  def index
    @projects = Project.recent
    @project = Project.new
  end

  def show
    @project = Project.find(params[:id])
    @contribution = @project.contributions.build
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

  def project_params
    params.require(:project).permit(
      :title,
      :category,
      :summary,
      :problem,
      :target_users,
      :success_metric,
      :status,
      :participation_needs
    )
  end
end
