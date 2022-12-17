class Quiz < ApplicationRecord
  has_many :games
  has_many :questions
end
