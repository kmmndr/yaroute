class Question < ApplicationRecord
  belongs_to :quiz
  has_many :responses
  has_many :answers, through: :responses
end
