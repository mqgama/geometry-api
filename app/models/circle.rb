class Circle < ApplicationRecord
  belongs_to :frame

  validates :center_x, presence: true
  validates :center_y, presence: true
  validates :diameter, presence: true, numericality: { greater_than: 0 }
end
