class Player < ApplicationRecord
  belongs_to :game
  belongs_to :user
  has_many :answers, dependent: :destroy

  before_validation :ensure_user_presence

  def ensure_user_presence
    self.user ||= User.new(first_name: name)
  end

  class << self
    def sort_by_highest_score
      joins(answers: { response: :question })
        .where(response: { value: true })
        .group('players.id')
        .select('players.*, SUM(questions.points) as score')
        .order('score DESC')
    end
  end

  def score
    answers
      .joins(:response).where(response: { value: true })
      .joins(:question).sum(:points)
  end
end
