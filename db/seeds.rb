robot = Project.find_by(title: "災害時に使える小型搬送ロボット") ||
        Project.find_or_initialize_by(title: "人の指示を聞いて動く小型屋内ロボット")

robot.update!(
  title: "人の指示を聞いて動く小型屋内ロボット",
  category: "ロボット",
  summary: "人の声・テキスト・ボタン指示を受け取り、屋内で安全に移動する小型ロボットの共同開発テーマ。",
  problem: "人の指示を理解し、屋内で安全に移動する小型ロボットを試作する。",
  target_users: "小型搬送、ロボット教材、施設内案内、ものづくり学習に関心がある人。",
  success_metric: <<~TEXT.strip,
    ・音声またはテキストで「前へ」「止まれ」「右へ」「左へ」を受け取れる
    ・指示から1秒以内に反応する
    ・最大速度を低速に制限する
    ・前方障害物を検知したら停止する
    ・非常停止ボタンで即停止できる
    ・30分以上の連続動作を目指す
    ・部品表と組み立て手順を公開できる
  TEXT
  status: "設計中",
  participation_needs: "機械設計、電気設計、ROS/Python、音声認識、安全レビュー、試作協力",
  specifications: <<~TEXT.strip,
    屋内、低速、軽量、人を乗せない小型移動ロボット。
    最初のMVPは、前進、停止、右旋回、左旋回、指定地点への移動に絞る。
    二輪差動駆動を基本とし、左モーター、右モーター、補助キャスターで構成する。
  TEXT
  features: <<~TEXT.strip,
    ・音声、テキスト、ボタンから指示を受け取る
    ・指示を move_forward / stop / turn_right / turn_left に変換する
    ・安全チェック後に低速で走行する
    ・障害物、非常停止、通信切断、バッテリー低下で停止する
    ・走行ログと試験結果を残す
  TEXT
  intended_uses: <<~TEXT.strip,
    ・荷物の小型搬送
    ・展示会や学校でのロボット教材
    ・高齢者施設や店舗での案内補助
    ・災害時の軽量物搬送の基礎研究
  TEXT
  scope_limits: <<~TEXT.strip,
    ・人を乗せない
    ・屋外公道を走らない
    ・階段昇降をしない
    ・重量物や危険物を運ばない
    ・人の身体に接触する作業をしない
    ・完全自律判断をMVPに含めない
    ・段差、階段、水場では使わない
  TEXT
  system_architecture: <<~TEXT.strip,
    人の指示 → 音声入力 / テキスト入力 / ボタン入力 → 指示解釈モジュール → 行動計画 → モーター制御 → 車輪・本体が移動。
    センサー入力は障害物検知に入り、安全停止モジュールが常に走行可否を判定する。
  TEXT
  mechanical_design: <<~TEXT.strip,
    二輪差動駆動を採用する。左モーター、右モーター、補助キャスターで前進、後退、右旋回、左旋回を行う。
    本体にはバッテリー、制御コンピュータ、距離センサー、非常停止ボタン、持ち手、カバー、メンテナンス口を配置する。
  TEXT
  electrical_design: <<~TEXT.strip,
    低電圧の試作構成に限定する。
    制御用コンピュータ、モータードライバ、左右モーター、バッテリー、非常停止スイッチ、距離センサー、カメラ、マイク、スピーカー、電源スイッチ、ヒューズを接続ブロック図で管理する。
  TEXT
  software_design: <<~TEXT.strip,
    入力層: 音声、テキスト、ボタン。
    理解層: 指示をコマンドに変換する。
    判断層: 今その指示を実行してよいか判定する。
    制御層: 速度、方向、停止を制御する。
    安全層: 障害物、非常停止、通信切断、バッテリー低下を監視する。
    初期版では、ROS 2を使う場合とシンプルなPython制御で作る場合を比較する。
  TEXT
  safety_design: <<~TEXT.strip,
    ・最大速度を制限する
    ・非常停止ボタンを設置する
    ・障害物検知で停止する
    ・人を乗せない
    ・危険物を運ばない
    ・屋外公道では使わない
    ・段差、階段、水場では使わない
    ・バッテリー異常時に停止する
    ・通信切断時に停止する
    ・試験時は監視者を置く
    ISO 12100のリスクアセスメントとリスク低減の考え方を参考にし、ISO 13482が扱う人の近くで動くロボットの安全要求も調査対象にする。
  TEXT
  manufacturing_steps: <<~TEXT.strip,
    1. フレームを組む
    2. 車輪とモーターを取り付ける
    3. バッテリーと電源スイッチを配置する
    4. 制御用コンピュータを固定する
    5. センサーを配置する
    6. 非常停止ボタンを付ける
    7. ソフトウェアを書き込む
    8. 無負荷テストを行う
    9. 低速走行テストを行う
    10. 障害物停止テストを行う
    高電力、危険な加工、公道走行は扱わない。
  TEXT
  test_plan: <<~TEXT.strip,
    □ 前進指示で前進する
    □ 停止指示で停止する
    □ 右旋回する
    □ 左旋回する
    □ 障害物検知で停止する
    □ 非常停止ボタンで停止する
    □ 30分連続動作する
    □ バッテリー低下時に警告する
    □ 通信切断時に停止する
  TEXT
  development_log: <<~TEXT.strip,
    2026-05-13 要求仕様を作成
    2026-05-14 車輪構成を二輪差動に決定
    2026-05-14 安全停止条件を追加
    2026-05-14 部品表、製造手順、試験項目の初期案を追加
  TEXT
  bill_of_materials: <<~TEXT.strip,
    制御用コンピュータ / 指示解釈と走行制御 / 1 / Raspberry Pi級または小型PC / 代替案あり / 放熱に注意
    モーター / 左右駆動 / 2 / 低速ギヤードモーター / トルク不足に注意
    モータードライバ / 左右モーター制御 / 1 / 低電圧対応品 / 過電流保護を確認
    車輪 / 移動 / 2 / ゴム車輪 / 床材との相性を確認
    補助キャスター / 姿勢安定 / 1 / 小型キャスター / 段差に注意
    距離センサー / 障害物検知 / 2以上 / ToFまたは超音波 / 誤検知を試験
    非常停止ボタン / 即停止 / 1 / 押しやすい大型ボタン / 配置を優先
    バッテリー / 電源 / 1 / 低電圧バッテリー / ヒューズと保護回路を確認
    フレーム材 / 本体構造 / 適量 / アルミフレームまたは樹脂板 / 角の保護が必要
  TEXT
  next_prototype: "二輪差動駆動の小型台車を作り、前進・停止・旋回・障害物停止を確認する。"
)

robot.ensure_development_stages
robot.development_stages.each do |stage|
  case stage.phase
  when "初期"
    stage.update!(
      image_description: "紙スケッチ、外形案、要求仕様、部品候補を整理する。",
      model_description: "本体サイズ、二輪差動、センサー位置、非常停止ボタン位置を紙面で検討する。",
      blueprint_notes: "人を乗せない、低速、屋内、軽量という安全な範囲を設計図に明記する。"
    )
  when "中期"
    stage.update!(
      image_description: "3D CAD、配線図、制御構成、試作シャーシを作る。",
      model_description: "左右モーター、補助キャスター、低電圧電源、距離センサーを載せた試作台車。",
      blueprint_notes: "部品配置図、センサー配置図、配線ブロック図、システム構成図を更新する。"
    )
  when "後期"
    stage.update!(
      image_description: "走行試験、障害物停止試験、音声指示テスト、安全レビューの状態。",
      model_description: "実利用に近い床面で低速走行し、停止距離と指示反応時間を測る検証モデル。",
      blueprint_notes: "危険源、想定リスク、対策、試験方法、残る課題を記録する。"
    )
  when "完成"
    stage.update!(
      image_description: "組立手順、部品表、ソースコード、試験結果、デモ動画を公開できる状態。",
      model_description: "低速移動、非常停止、障害物停止、基本指示への反応を確認済みの完成モデル。",
      blueprint_notes: "製造、運用、保守、公開に必要な最終図面と手順を整える。"
    )
  end
end

robot.project_parts.destroy_all
[
  ["駆動", "左右モーター", "移動用", "2", "未定", "未定", "積載に必要なトルクを確認", "調査中"],
  ["制御", "制御用コンピュータ", "指示解釈と走行制御", "1", "Raspberry Pi級または小型PC", "未定", "放熱と電源容量に注意", "候補調査"],
  ["安全", "非常停止ボタン", "緊急停止", "1", "押しやすい大型ボタン", "未定", "上面中央に配置", "必須"],
  ["検知", "距離センサー", "障害物検知", "2以上", "ToFまたは超音波", "未定", "誤検知と死角を試験", "調査中"],
  ["電源", "低電圧バッテリー", "走行と制御の電源", "1", "保護回路付き", "未定", "ヒューズと電源スイッチを確認", "未検証"]
].each do |category, name, purpose, quantity, candidate, price, note, status|
  robot.project_parts.create!(
    category: category,
    name: name,
    purpose: purpose,
    quantity: quantity,
    candidate: candidate,
    estimated_price: price,
    note: note,
    status: status
  )
end

robot.project_risks.destroy_all
[
  ["人に接触する", "転倒、けが", "速度が速い、障害物検知が遅い", "高", "中", "高", "低速制限、障害物検知、非常停止", "停止距離テスト", "死角の評価", "対策設計中"],
  ["バッテリー異常", "発熱、停止不能", "過負荷、配線不良", "高", "低", "中", "ヒューズ、電源スイッチ、温度監視", "低負荷・高負荷テスト", "温度監視方法", "未検証"],
  ["通信切断", "意図しない継続走行", "無線不安定、制御PC停止", "中", "中", "中", "通信断で停止するフェイルセーフ", "通信遮断テスト", "復帰手順", "設計中"]
].each do |hazard, accident, cause, severity, likelihood, level, mitigation, test_method, residual_issue, status|
  robot.project_risks.create!(
    hazard: hazard,
    accident: accident,
    cause: cause,
    severity: severity,
    likelihood: likelihood,
    level: level,
    mitigation: mitigation,
    test_method: test_method,
    residual_issue: residual_issue,
    status: status
  )
end

robot.project_test_items.destroy_all
[
  ["前進指示テスト", "基本指示に1秒以内で反応", "音声・テキストで前進を入力", "1秒以内に低速前進し、ログが残る", "未実施"],
  ["障害物停止テスト", "前方障害物を検知したら停止", "前方に障害物を置いて低速接近", "接触前に停止する", "未実施"],
  ["非常停止テスト", "非常停止ボタンで即停止", "走行中に非常停止を押す", "モーター出力が即時停止する", "未実施"],
  ["30分連続動作テスト", "30分以上の連続動作", "低速巡回を30分継続", "異常停止や過熱がない", "未実施"]
].each do |title, relation, method, criteria, status|
  robot.project_test_items.create!(
    title: title,
    success_relation: relation,
    test_method: method,
    acceptance_criteria: criteria,
    status: status
  )
end

robot.project_tasks.destroy_all
[
  ["20kg相当を想定したモーター候補調査", "部品表 > 左右モーター / 要求仕様 > 積載", "募集中", "担当者募集中", "必要トルク、価格、入手性、制御しやすさを比較する。"],
  ["非常停止ボタン位置レビュー", "安全設計 > 非常停止", "募集中", "レビュー待ち", "上面中央に配置する案の押しやすさと配線を確認する。"],
  ["Python制御とROS 2構成の比較", "ソフトウェア設計", "募集中", "未着手", "初期MVPに適した制御構成を比較表にする。"],
  ["障害物停止テスト手順作成", "試験項目 > 障害物停止", "募集中", "未着手", "停止距離、速度、センサー位置の記録方法を決める。"]
].each do |title, related_area, assignee, status, description|
  robot.project_tasks.create!(
    title: title,
    related_area: related_area,
    assignee: assignee,
    status: status,
    description: description
  )
end

robot.project_roles.destroy_all
[
  ["機械設計", "フレーム、車輪、重心、積載構造を考える。"],
  ["電気設計", "電源、モータードライバ、非常停止、センサー配線を考える。"],
  ["ソフトウェア", "音声コマンド、走行制御、安全停止、ログ保存を実装する。"],
  ["安全レビュー", "危険源、停止条件、試験項目、運用制約を確認する。"],
  ["試作協力", "部品調達、組み立て、低速走行テストを行う。"]
].each do |name, description|
  robot.project_roles.create!(name: name, description: description, status: "募集中")
end

robot.project_artifacts.destroy_all
[
  ["要求仕様書", "仕様", "MVP範囲、やらないこと、成功条件を整理した文書。", "作成中"],
  ["システム構成図", "設計図", "入力、指示解釈、行動計画、制御、安全停止の構成図。", "作成中"],
  ["部品表", "BOM", "駆動、制御、安全、検知、電源の候補部品表。", "作成中"],
  ["安全設計メモ", "安全", "危険源、対策、試験方法をまとめたリスク台帳。", "作成中"],
  ["試験結果", "検証", "前進、停止、障害物停止、非常停止の試験結果。", "未着手"]
].each do |title, kind, notes, status|
  robot.project_artifacts.create!(title: title, kind: kind, notes: notes, status: status)
end

recipe = Project.find_or_initialize_by(title: "地域の余り食材を使い切る共同レシピ")
recipe.update!(
  category: "料理",
  summary: "家庭や店で余りがちな食材から、共同で検証できる保存食・日常食レシピを作る。",
  problem: "余り食材は種類と量が毎回違うため、検索レシピでは使い切りにくい。",
  target_users: "家庭、飲食店、子ども食堂、地域イベントの調理担当者。",
  success_metric: "3種類以下の主材料で作れ、調理時間30分以内、複数人の試作で再現できる。",
  status: "構想",
  participation_needs: "レシピ試作、栄養確認、写真記録",
  specifications: "主材料3種類以内、調理30分以内、家庭用調理器具で再現可能、冷蔵3日保存を目標。",
  features: "食材入力、代替材料候補、調理手順、試作メモ、栄養とアレルギー確認。",
  intended_uses: "家庭、飲食店、子ども食堂、地域イベント。",
  scope_limits: "衛生上危険な保存、アレルゲン未確認の提供、大量製造はMVP対象外。",
  system_architecture: "食材入力 → 代替案 → 調理手順 → 試作記録 → 改善案。",
  mechanical_design: "調理器具、保存容器、提供導線を整理する。",
  electrical_design: "電気設計は対象外。必要に応じて調理家電の使用条件を記録する。",
  software_design: "食材、手順、試作結果、写真、栄養確認を記録する。",
  safety_design: "衛生管理、アレルゲン表示、保存温度、試食時の注意を整理する。",
  manufacturing_steps: "材料確認、下処理、調理、冷却、保存、試食、記録。",
  test_plan: "□ 30分以内に作れる\n□ 3種類以下の主材料で作れる\n□ 複数人が再現できる\n□ 保存条件を記録できる",
  development_log: "2026-05-14 共同レシピの初期案を作成",
  bill_of_materials: "食材 / 主材料 / 3種類以内 / 余り食材\n保存容器 / 冷蔵保存 / 必要数 / 密閉容器",
  next_prototype: "余り野菜を使った保存食レシピを3件試作する。"
)

recipe.ensure_development_stages
recipe.save!
