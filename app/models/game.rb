class Game < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  belongs_to :current_question, class_name: 'Question', optional: true
  has_many :players, dependent: :destroy
  has_many :answers, through: :players
  has_many :questions, through: :quiz

  before_validation :set_default_user
  before_validation :set_code

  def set_default_user
    self.user ||= quiz.user
  end

  def set_code
    self.code ||= rand(100000..999999)
  end

  def self.waiting_players
    where(started_at: nil)
  end

  def self.started
    where.not(started_at: nil)
  end

  def waiting_players?
    started_at.nil?
  end

  def started?
    started_at.present?
  end

  def starting?
    started? && current_question.nil?
  end

  def start!(at: Time.zone.now)
    touch(:started_at, time: at)
  end

  def next_question!
    ids = questions.ids
    current_id = current_question&.id

    if current_id.nil?
      self.current_question_id = ids.first
    else
      next_idx = ids.index(current_id) + 1
      next_id = ids[next_idx]

      return if next_id.nil?

      self.current_question_id = next_id
    end

    self.current_question_at = Time.zone.now
    save!

    self
  end

  def current_question_expiration
    current_question&.duration&.seconds&.since(current_question_at)
  end

  def waiting_delay
    end_date = if starting?
                 started_at
               elsif current_question_expiration.present?
                 current_question_expiration
               end

    return 0 if end_date.nil?

    delay_until(end_date)
  end

  def next_question?
    started? && waiting_delay == 0
  end

  def reset!
    Answer.where(id: answers).destroy_all

    update!(
      started_at: nil,
      current_question_id: nil
    )

    self
  end

  private

  def delay_until(end_date, ref: Time.zone.now)
    delay = (end_date - Time.zone.now)
    [0, delay].max
  end
end
