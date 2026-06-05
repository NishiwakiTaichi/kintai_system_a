class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  validate :finished_at_is_invalid_without_a_started_at
  validate :started_at_than_finished_at_fast_if_invalid
  validate :started_at_and_finished_at_pair, on: :edit_attendance

  private

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    return unless started_at.present? && finished_at.present?

    errors.add(:started_at, "より早い退社時間は無効です") if started_at > finished_at
  end

  def started_at_and_finished_at_pair
    # 当日出勤中（今日・出社済み・退社未記録）の場合のみスキップ
    return if persisted? &&
              worked_on == Date.current &&
              started_at_in_database.present? &&
              finished_at_in_database.nil?
    return unless started_at.present? && finished_at.blank?

    errors.add(:finished_at, "が必要です")
  end
end
