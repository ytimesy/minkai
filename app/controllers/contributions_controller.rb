class ContributionsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @contribution = @project.contributions.build(contribution_params)

    if @contribution.save
      redirect_to @project, notice: "参加メモを追加しました。"
    else
      render "projects/show", status: :unprocessable_entity
    end
  end

  private

  def contribution_params
    params.require(:contribution).permit(:name, :role, :body, :kind)
  end
end
