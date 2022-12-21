class Account < ApplicationRecord
  belongs_to :user

  attr_accessor :plain_password

  validates :login, uniqueness: { allow_nil: true }, presence: true
  # https://github.com/bdmac/strong_password#details
  #
  # The first byte counts as 4 bits.
  # The next 7 bytes count as 2 bits each.
  # The next 12 bytes count as 1.5 bits each.
  # Anything beyond that counts as 1 bit each.
  # Mixed case + non-alphanumeric = up to 6 extra bits.
  #
  validates :plain_password, password_strength: { min_entropy: 30 }, if: proc { |a| Rails.env.production? && !a.new_record? && a.changed.include?('password_hash') }

  before_validation :ensure_user_presence

  def ensure_user_presence
    self.user ||= User.new(first_name: login)
  end

  def password
    SCrypt::Password.new(password_hash)
  end

  def password=(value)
    self.plain_password = value
    self.password_hash = SCrypt::Password.create(value)
  end
end
