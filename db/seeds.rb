# 管理者ユーザーを作成
admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  name:       "管理者 太郎",
  password:   "password",
  department: "管理部",
  admin:      true,
  basic_time: nil,
  work_time:  nil
)
admin.save!

# 一般ユーザー50名（日本語名）
users_data = [
  { name: "中山 海斗",   department: "開発部" },
  { name: "谷口 優伶",   department: "営業部" },
  { name: "遠藤 真央",   department: "開発部" },
  { name: "松尾 誠",     department: "総務部" },
  { name: "安藤 美緒",   department: "営業部" },
  { name: "林 賢",       department: "開発部" },
  { name: "佐々木 悠斗", department: "総務部" },
  { name: "上田 陽太",   department: "開発部" },
  { name: "前田 陽子",   department: "営業部" },
  { name: "吉田 吾奈",   department: "開発部" },
  { name: "高田 紬",     department: "総務部" },
  { name: "高田 翔太",   department: "開発部" },
  { name: "上田 匠",     department: "営業部" },
  { name: "藤田 大地",   department: "開発部" },
  { name: "福田 彩花",   department: "総務部" },
  { name: "池田 豪",     department: "開発部" },
  { name: "池田 美穂",   department: "営業部" },
  { name: "森田 一郎",   department: "開発部" },
  { name: "木村 さくら", department: "総務部" },
  { name: "山田 太郎",   department: "営業部" },
  { name: "田中 花子",   department: "開発部" },
  { name: "鈴木 健",     department: "総務部" },
  { name: "伊藤 明",     department: "開発部" },
  { name: "渡辺 奈々",   department: "営業部" },
  { name: "小林 勇",     department: "開発部" },
  { name: "加藤 由美",   department: "総務部" },
  { name: "吉田 浩",     department: "営業部" },
  { name: "山口 敦",     department: "開発部" },
  { name: "佐藤 恵",     department: "総務部" },
  { name: "松本 拓也",   department: "開発部" },
  { name: "井上 千春",   department: "営業部" },
  { name: "木下 隆",     department: "開発部" },
  { name: "橋本 愛",     department: "総務部" },
  { name: "石川 亮",     department: "営業部" },
  { name: "村田 麻衣",   department: "開発部" },
  { name: "西村 哲",     department: "総務部" },
  { name: "清水 結衣",   department: "開発部" },
  { name: "浜田 翼",     department: "営業部" },
  { name: "小山 直樹",   department: "開発部" },
  { name: "坂本 彩",     department: "総務部" },
  { name: "工藤 剛",     department: "営業部" },
  { name: "大野 美咲",   department: "開発部" },
  { name: "古川 修",     department: "総務部" },
  { name: "原田 智子",   department: "開発部" },
  { name: "島田 竜也",   department: "営業部" },
  { name: "内田 葵",     department: "開発部" },
  { name: "菊地 康平",   department: "総務部" },
  { name: "岡田 香織",   department: "営業部" },
  { name: "長谷川 大",   department: "開発部" },
  { name: "平野 紗希",   department: "総務部" },
]

users_data.each_with_index do |data, i|
  user = User.find_or_initialize_by(email: "user#{i + 1}@example.com")
  user.assign_attributes(
    name:       data[:name],
    password:   "password",
    department: data[:department],
    admin:      false,
    basic_time: nil,
    work_time:  nil
  )
  user.save!
end
