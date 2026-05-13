class ProjectSectionDetailsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @project_section_detail = @project.project_section_details.build(project_section_detail_params)

    if @project_section_detail.save
      redirect_to redirect_path, notice: "細かい設計を追加しました。"
    else
      redirect_to redirect_path, alert: @project_section_detail.errors.full_messages.to_sentence
    end
  end

  private

  def project_section_detail_params
    params.require(:project_section_detail).permit(:section, :subsection, :title, :kind, :body, :status, :position)
  end

  def redirect_path
    section = @project_section_detail.section.presence || "overview"
    subsection = @project_section_detail.subsection.presence

    if section == "overview"
      project_path(@project)
    elsif section == "blueprints" && subsection.present? && subsection != "overview"
      project_design_section_path(@project, section: section, design_section: subsection)
    else
      project_section_path(@project, section: section)
    end
  end
end
