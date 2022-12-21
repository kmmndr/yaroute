class Game < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  has_many :players, dependent: :destroy
  has_many :answers, through: :players
  has_many :questions, through: :quiz

  before_validation :set_default_user

  def set_default_user
    self.user ||= quiz.user
  end
end
