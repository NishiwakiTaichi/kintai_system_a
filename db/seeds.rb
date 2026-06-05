# 管理者ユーザーを作成
admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  name: "管理者 太郎",
  password: "password",
  affiliation: "管理部",
  admin: true,
  superior: false,
  employee_number: "A001",
  uid: "UID-A001",
  designated_work_start_time: Time.zone.parse("2000-01-01 09:00:00"),
  designated_work_end_time: Time.zone.parse("2000-01-01 18:00:00"),
  basic_time: nil,
  work_time: nil
)
admin.save!

# 上長ユーザーを作成
superior1 = User.find_or_initialize_by(email: "superior1@example.com")
superior1.assign_attributes(
  name: "上長 一郎",
  password: "password",
  affiliation: "開発部",
  admin: false,
  superior: true,
  employee_number: "S001",
  uid: "UID-S001",
  designated_work_start_time: Time.zone.parse("2000-01-01 09:00:00"),
  designated_work_end_time: Time.zone.parse("2000-01-01 18:00:00"),
  basic_time: nil,
  work_time: nil
)
superior1.save!

superior2 = User.find_or_initialize_by(email: "superior2@example.com")
superior2.assign_attributes(
  name: "上長 二郎",
  password: "password",
  affiliation: "営業部",
  admin: false,
  superior: true,
  employee_number: "S002",
  uid: "UID-S002",
  designated_work_start_time: Time.zone.parse("2000-01-01 09:00:00"),
  designated_work_end_time: Time.zone.parse("2000-01-01 18:00:00"),
  basic_time: nil,
  work_time: nil
)
superior2.save!

# 一般ユーザー50名（日本語名）
users_data = [
  { name: "中山 海斗",   affiliation: "開発部" },
  { name: "谷口 優伶",   affiliation: "営業部" },
  { name: "遠藤 真央",   affiliation: "開発部" },
  { name: "松尾 誠", affiliation: "総務部" },
  { name: "安藤 美緒", affiliation: "営業部" },
  { name: "林 賢", affiliation: "開発部" },
  { name: "佐々木 悠斗", affiliation: "総務部" },
  { name: "上田 陽太",   affiliation: "開発部" },
  { name: "前田 陽子",   affiliation: "営業部" },
  { name: "吉田 吾奈",   affiliation: "開発部" },
  { name: "高田 紬", affiliation: "総務部" },
  { name: "高田 翔太", affiliation: "開発部" },
  { name: "上田 匠", affiliation: "営業部" },
  { name: "藤田 大地",   affiliation: "開発部" },
  { name: "福田 彩花",   affiliation: "総務部" },
  { name: "池田 豪", affiliation: "開発部" },
  { name: "池田 美穂",   affiliation: "営業部" },
  { name: "森田 一郎",   affiliation: "開発部" },
  { name: "木村 さくら", affiliation: "総務部" },
  { name: "山田 太郎",   affiliation: "営業部" },
  { name: "田中 花子",   affiliation: "開発部" },
  { name: "鈴木 健",     affiliation: "総務部" },
  { name: "伊藤 明",     affiliation: "開発部" },
  { name: "渡辺 奈々", affiliation: "営業部" },
  { name: "小林 勇", affiliation: "開発部" },
  { name: "加藤 由美", affiliation: "総務部" },
  { name: "吉田 浩",     affiliation: "営業部" },
  { name: "山口 敦",     affiliation: "開発部" },
  { name: "佐藤 恵",     affiliation: "総務部" },
  { name: "松本 拓也",   affiliation: "開発部" },
  { name: "井上 千春",   affiliation: "営業部" },
  { name: "木下 隆",     affiliation: "開発部" },
  { name: "橋本 愛",     affiliation: "総務部" },
  { name: "石川 亮",     affiliation: "営業部" },
  { name: "村田 麻衣", affiliation: "開発部" },
  { name: "西村 哲", affiliation: "総務部" },
  { name: "清水 結衣", affiliation: "開発部" },
  { name: "浜田 翼", affiliation: "営業部" },
  { name: "小山 直樹", affiliation: "開発部" },
  { name: "坂本 彩",     affiliation: "総務部" },
  { name: "工藤 剛",     affiliation: "営業部" },
  { name: "大野 美咲", affiliation: "開発部" },
  { name: "古川 修", affiliation: "総務部" },
  { name: "原田 智子",   affiliation: "開発部" },
  { name: "島田 竜也",   affiliation: "営業部" },
  { name: "内田 葵", affiliation: "開発部" },
  { name: "菊地 康平",   affiliation: "総務部" },
  { name: "岡田 香織",   affiliation: "営業部" },
  { name: "長谷川 大",   affiliation: "開発部" },
  { name: "平野 紗希",   affiliation: "総務部" }
]

users_data.each_with_index do |data, i|
  user = User.find_or_initialize_by(email: "user#{i + 1}@example.com")
  user.assign_attributes(
    name: data[:name],
    password: "password",
    affiliation: data[:affiliation],
    admin: false,
    superior: false,
    employee_number: "U#{format('%03d', i + 1)}",
    uid: "UID-#{format('%03d', i + 1)}",
    designated_work_start_time: Time.zone.parse("2000-01-01 09:00:00"),
    designated_work_end_time: Time.zone.parse("2000-01-01 18:00:00"),
    basic_time: nil,
    work_time: nil
  )
  user.save!
end
