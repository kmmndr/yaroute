class User < ApplicationRecord
  has_one :account, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :players, dependent: :destroy
  has_many :quizzes, dependent: :destroy
end
