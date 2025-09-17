class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_error

  validates :center_x, presence: true
  validates :center_y, presence: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }
end
