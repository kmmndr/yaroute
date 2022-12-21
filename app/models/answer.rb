class Answer < ApplicationRecord
  belongs_to :player
  belongs_to :response
  has_one :question, through: :response

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
end
