class Quiz < ApplicationRecord
  belongs_to :user
  has_many :games, dependent: :destroy
  has_many :questions, dependent: :destroy
end
