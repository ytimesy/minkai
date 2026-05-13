Project.find_or_create_by!(title: "災害時に使える小型搬送ロボット") do |project|
  project.category = "ロボット"
  project.summary = "避難所や狭い通路で水・医薬品・工具を安全に運ぶ小型ロボットを設計する。"
  project.problem = "災害直後は人手が足りず、重量物の運搬が復旧や支援のボトルネックになる。"
  project.target_users = "避難所運営者、消防・自治体職員、高齢者やけが人を支援する地域住民。"
  project.success_metric = "20kgを載せて段差2cmを越えられ、1時間以上連続稼働し、部品費10万円以内で試作できる。"
  project.status = "設計中"
  project.participation_needs = "機械設計、電源設計、現場ヒアリング"
  project.specifications = "積載20kg、段差2cm、連続稼働1時間、部品費10万円以内、防水は生活防水相当。"
  project.features = "手押し補助、自律追従、緊急停止、荷崩れ警告、現場で交換できるバッテリー。"
end

Project.find_or_create_by!(title: "地域の余り食材を使い切る共同レシピ") do |project|
  project.category = "料理"
  project.summary = "家庭や店で余りがちな食材から、共同で検証できる保存食・日常食レシピを作る。"
  project.problem = "余り食材は種類と量が毎回違うため、検索レシピでは使い切りにくい。"
  project.target_users = "家庭、飲食店、子ども食堂、地域イベントの調理担当者。"
  project.success_metric = "3種類以下の主材料で作れ、調理時間30分以内、複数人の試作で再現できる。"
  project.status = "構想"
  project.participation_needs = "レシピ試作、栄養確認、写真記録"
  project.specifications = "主材料3種類以内、調理30分以内、家庭用調理器具で再現可能、冷蔵3日保存を目標。"
  project.features = "食材入力、代替材料候補、調理手順、試作メモ、栄養とアレルギー確認。"
end

Project.find_each do |project|
  project.ensure_development_stages
  project.save!
end
