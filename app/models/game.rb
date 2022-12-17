class Game < ApplicationRecord
  belongs_to :quiz
  has_many :players
  has_many :answers, through: :players
  has_many :questions, through: :quiz
end
