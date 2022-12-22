class Question < ApplicationRecord
  belongs_to :quiz
  has_many :responses, dependent: :destroy
  has_many :answers, through: :responses

  accepts_nested_attributes_for :responses, allow_destroy: true
end
