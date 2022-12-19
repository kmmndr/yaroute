class User < ApplicationRecord
  has_many :players, dependent: :destroy
end
