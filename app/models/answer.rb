class Answer < ApplicationRecord
  belongs_to :player
  belongs_to :response
  has_one :question, through: :response
  has_one :game, through: :player

  validates :response_id, uniqueness: { scope: :player_id }

  class << self
    def good
      joins(:response).where(response: { value: true })
    end

    def bad
      joins(:response).where(response: { value: false })
    end
  end

  def good?
    response.value == true
  end

  def bad?
    response.value == false
  end

  def eligible?
    question_active?
  end

  def question_active?
    return false if game.delay_elapsed?

    game.current_question == question
  end
end
