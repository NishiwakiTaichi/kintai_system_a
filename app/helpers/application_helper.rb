module ApplicationHelper
  def admin_user?
    current_user&.admin?
  end

  # 勤怠の基本情報（TimeオブジェクトのHH:MM）を時間の小数点表示に変換する
  def format_basic_info(time)
    return "0.00" if time.nil?
    format("%.2f", ((time.hour * 60) + time.min) / 60.0)
  end

  # 出勤時間と退勤時間から在社時間（時間の小数点表示）を計算して返す
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end

  # 時刻を15分単位に切り捨てて返す
  def floor_to_15min(time)
    return nil if time.nil?
    time.change(min: (time.min / 15) * 15, sec: 0)
  end

  # 曜日番号に応じたBootstrapテキストカラークラスを返す
  def day_color_class(date)
    case date.wday
    when 0 then "text-danger"  # 日曜：赤
    when 6 then "text-primary" # 土曜：青
    else ""                    # 平日：黒
    end
  end

end
