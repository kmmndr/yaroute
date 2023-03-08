class Game < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  belongs_to :current_question, class_name: 'Question', optional: true
  has_many :players, dependent: :destroy
  has_many :answers, through: :players
  has_many :questions, through: :quiz

  before_validation :set_default_user
  before_validation :set_code

  def current_answers
    @current_answers ||= current_question
                         .answers
                         .joins(player: :game).where(player: { game_id: id })
  end

  def response_answers(response)
    current_answers.where(response: response) if response.present?
  end

  def response_percentage(response)
    return nil if current_answers.count == 0

    response_answers(response).count * 100 / current_answers.count
  end

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

  def self.not_finished
    where(finished_at: nil)
  end

  def self.finished
    where.not(finished_at: nil)
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

  def finished?
    finished_at.present?
  end

  def start!(at: Time.zone.now)
    touch(:started_at, time: at)
  end

  def finish!(at: Time.zone.now)
    touch(:finished_at, time: at)
  end

  def next_question
    return @next_question if @next_question.present?

    ids = questions.ids
    current_id = current_question&.id

    next_id = if current_id.nil?
                ids.first
              else
                current_idx = ids.index(current_id)

                next_idx = current_idx + 1
                ids[next_idx]
              end

    @next_question = if next_id.nil?
                       nil
                     else
                       questions.find_by(id: next_id)
                     end
  end

  def next_question!
    return if next_question.nil?

    update!(
      current_question_id: next_question.id,
      current_question_at: Time.zone.now
    )

    self
  end

  def next_question?
    started? && !last_question?
  end

  def last_question?
    current_question.present? && next_question.nil?
  end

  def next_step!
    if next_question?
      next_question!
    elsif last_question?
      update(current_question_id: nil)
      finish!
    end
  end

  def current_question_expiration
    current_question&.duration&.seconds&.since(current_question_at)
  end

  def remaining_time
    end_date = if starting?
                 started_at
               elsif current_question_expiration.present?
                 current_question_expiration
               end

    return 0 if end_date.nil?

    delay_until(end_date)
  end

  def remaining_time?
    remaining_time > 0
  end

  def delay_elapsed?
    remaining_time == 0
  end

  def reset!
    Answer.where(id: answers).destroy_all

    update!(
      current_question_id: nil,
      started_at: nil,
      finished_at: nil
    )

    self
  end

  private

  def delay_until(end_date, ref: Time.zone.now)
    delay = (end_date - ref)
    [0, delay].max
  end
end
