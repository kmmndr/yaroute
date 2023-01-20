class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  def player_in_game(game)
    players.find_by(game: game)
  end

  def can?(action, subject = nil)
    AbilitiesHandler.new.abilities.allowed?(self, action, subject)
  end
end
