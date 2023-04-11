class Quiz < ApplicationRecord
  belongs_to :user
  has_many :games, dependent: :destroy
  has_many :questions, -> { ordered }, dependent: :destroy
end
