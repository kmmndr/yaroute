class Response < ApplicationRecord
  belongs_to :question
  has_many :answers, dependent: :destroy

  def self.ordered
    order(:position, :id)
  end
end
