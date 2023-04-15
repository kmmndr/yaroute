class Quiz < ApplicationRecord
  belongs_to :user
  has_many :games, dependent: :destroy
  has_many :questions, -> { enabled.ordered }, dependent: :destroy
  has_many :all_questions, -> { ordered }, class_name: 'Question', dependent: :destroy
end
