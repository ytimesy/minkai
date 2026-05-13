class ProjectPartsController < ApplicationController
  before_action :set_project
  before_action :set_part

  def new_component
    if @part.valid_child_project
      redirect_to @part.valid_child_project
      return
    end
  end

  def create_component
    if @part.valid_child_project
      redirect_to @part.valid_child_project, notice: "既存の子開発ページを開きました。"
      return
    end

    child = build_component_project
    ActiveRecord::Base.transaction do
      child.save!
      create_component_defaults(child)
      @part.update!(child_project: child, development_status: "開発テーマ化済み")
      append_parent_log(child)
    end

    redirect_to child, notice: "部品の子開発ページを作成しました。"
  end

  def sync_from_child
    child = @part.valid_child_project
    unless child
      redirect_to project_section_path(@project, section: "bom"), alert: "子開発ページがありません。"
      return
    end

    @part.update!(
      candidate: params.dig(:project_part, :candidate).presence || child.bill_of_materials.presence || @part.candidate,
      procurement_policy: params.dig(:project_part, :procurement_policy).presence || @part.procurement_policy,
      estimated_price: params.dig(:project_part, :estimated_price).presence || @part.estimated_price,
      status: params.dig(:project_part, :status).presence || "候補確定",
      note: params.dig(:project_part, :note).presence || @part.note,
      development_status: "親BOM反映済み"
    )

    redirect_to project_section_path(@project, section: "bom"), notice: "子開発ページの内容を親BOMへ反映しました。"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_part
    @part = @project.project_parts.find(params[:id])
  end

  def build_component_project
    Project.new(
      title: @part.component_title,
      category: @project.category,
      project_type: "component_project",
      parent_project: @project,
      source_bom_item: @part,
      summary: "#{@project.title}で使う#{@part.name}を選定・検証する開発ページ。",
      problem: "#{@part.purpose}のために必要な#{@part.name}を、安全性、入手性、接続仕様、試験方法まで整理する。",
      target_users: "#{@project.title}の開発参加者、#{@part.category}担当者、安全レビュー担当者。",
      success_metric: component_success_metric,
      status: "調査中",
      participation_needs: "候補調査、設計レビュー、試験手順作成、親BOMへの反映",
      specifications: component_requirements,
      features: "候補比較、Make or Buy判断、接続仕様、試験項目、親プロジェクトへの反映。",
      intended_uses: "#{@project.title}の#{@part.purpose}に使う。",
      scope_limits: "汎用部品の過剰な個別開発はしない。安全重要部品は安全レビューを必須にする。",
      system_architecture: "親プロジェクト → BOM #{part_label} → 子開発ページ → 候補比較 → 試験 → 親BOMへ反映。",
      basic_design: "購入、自作、外注、既製品改造のどれが妥当かを比較する。",
      detail_design: "取り付け位置、配線、電源、制御用コンピュータとの接続、ソフトウェア側の入力形式を整理する。",
      data_transition_design: "候補案、試験結果、リスク、採用判断を親BOMへ戻す。",
      mechanical_design: "取り付け位置、固定方法、メンテナンス性、保護方法を整理する。",
      electrical_design: "電源、信号線、通信方式、フェイルセーフ、配線抜け時の扱いを整理する。",
      software_design: "入力値、出力状態、親ロボットへの通知形式を整理する。例: obstacle_detected = true / false。",
      safety_design: @part.safety_critical? ? "安全レビュー必須。誤検知、検知漏れ、故障、配線抜け、停止不能を評価する。" : "通常リスク、故障時の影響、代替案を整理する。",
      manufacturing_steps: "候補調査、比較、試作取り付け、接続、試験、親BOM反映の順で進める。",
      test_plan: component_test_plan,
      development_log: "#{Time.zone.today} #{part_label}から子開発ページを作成。",
      bill_of_materials: @part.candidate,
      next_prototype: "候補を3つ比較し、試験可能な構成を1つ選ぶ。"
    )
  end

  def create_component_defaults(child)
    child.project_tasks.create!([
      { title: "候補部品を3つ調査する", related_area: "#{@part.requirement_ids} / #{part_label}", assignee: "募集中", status: "未着手", description: "価格、入手性、仕様、実装難易度を比較する。" },
      { title: "検知距離と応答速度を比較する", related_area: "#{@part.requirement_ids} / #{part_label} / #{@part.test_ids}", assignee: "募集中", status: "未着手", description: "親プロジェクトの要求と試験に合うか確認する。" },
      { title: "取り付け位置を決める", related_area: "#{part_label}", assignee: "募集中", status: "未着手", description: "配線、保守、死角、安全性を含めて決める。" },
      { title: "親プロジェクトの部品表へ反映する", related_area: "#{@part.requirement_ids} / #{@part.test_ids}", assignee: "募集中", status: "未着手", description: "候補、価格、調達方針、状態を親BOMへ戻す。" }
    ])

    child.project_artifacts.create!([
      { title: "候補比較表", kind: "候補案", notes: "価格、精度、応答速度、実装難易度、入手性、安全性を比較する。", status: "未作成" },
      { title: "接続仕様", kind: "設計", notes: "入力、出力、親ロボットへの通知形式をまとめる。", status: "未作成" },
      { title: "親BOM反映メモ", kind: "反映", notes: "採用候補、調達方針、状態、注意点を親へ戻す。", status: "未作成" }
    ])
  end

  def append_parent_log(child)
    line = "#{Time.zone.today} #{part_label} #{@part.name}から「#{child.title}」を作成しました。"
    @project.update!(development_log: [@project.development_log, line].compact_blank.join("\n"))
  end

  def component_success_metric
    [
      "REQ-C001 #{@part.name}の候補を3つ比較できる",
      "REQ-C002 #{@part.purpose}に必要な仕様を満たす候補を選べる",
      "REQ-C003 親プロジェクトの#{@part.requirement_ids.presence || "要求"}と接続できる",
      "REQ-C004 #{@part.test_ids.presence || "関連試験"}で検証できる"
    ].join("\n")
  end

  def component_requirements
    [
      "対象部品: #{part_label} #{@part.name}",
      "用途: #{@part.purpose}",
      "関連要求: #{@part.requirement_ids.presence || "未設定"}",
      "関連試験: #{@part.test_ids.presence || "未設定"}",
      "調達方針: #{@part.procurement_policy_label}",
      "価格上限、入手性、安全条件を確認する。"
    ].join("\n")
  end

  def component_test_plan
    [
      "□ 候補を3種類以上比較できる",
      "□ 親プロジェクトの関連要求を満たせる",
      "□ 関連試験と接続できる",
      "□ 故障時・通信切断時の安全側動作を確認できる",
      "□ 親BOMへ候補、価格、調達方針、状態を反映できる"
    ].join("\n")
  end

  def part_label
    @part.tracking_id
  end
end
