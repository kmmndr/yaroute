class Quiz < ApplicationRecord
  has_many :games, dependent: :destroy
  has_many :questions, dependent: :destroy
end
