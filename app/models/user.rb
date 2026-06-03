require "csv"

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :attendances, dependent: :destroy
  has_many :attendance_change_applications, dependent: :destroy # 勤怠変更申請（申請者として）

  # 上長ユーザーの中から指定ユーザーを除いたスコープ
  scope :supervisors_except, ->(user) { where(superior: true).where.not(id: user.id) }

  # CSVファイルからユーザーを一括登録する
  def self.import(csv_file)
    CSV.foreach(csv_file.path, headers: true, encoding: "UTF-8") do |row|
      data = row.to_h

      user = User.new(
        name: data["name"],
        email: data["email"],
        affiliation: data["affiliation"],
        employee_number: data["employee_number"],
        uid: data["uid"],
        basic_time: parse_time(data["basic_work_time"]),
        designated_work_start_time: parse_time(data["designated_work_start_time"]),
        designated_work_end_time: parse_time(data["designated_work_end_time"]),
        superior: data["superior"] == "true",
        admin: data["admin"] == "true",
        password: data["password"],
        password_confirmation: data["password"]
      )
      user.save
    end
  end

  # "09:00" のような文字列を datetime 型に変換する
  def self.parse_time(value)
    return nil if value.blank?

    Time.zone.parse("2000-01-01 #{value}")
  end
end
