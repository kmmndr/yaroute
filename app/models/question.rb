class Question < ApplicationRecord
  belongs_to :quiz
  has_many :responses, -> { ordered }, dependent: :destroy
  has_many :answers, through: :responses

  has_one_attached :image

  accepts_nested_attributes_for :responses, allow_destroy: true

  def self.ordered
    order(:position, :id)
  end

  def self.enabled
    where.not(disabled: true)
  end

  def disabled?
    disabled == true
  end

  def enabled?
    !disabled?
  end
end
