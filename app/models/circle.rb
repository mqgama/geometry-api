class Circle < ApplicationRecord
  belongs_to :frame

  validates :center_x, presence: true
  validates :center_y, presence: true
  validates :diameter, presence: true, numericality: { greater_than: 0 }

  validates_with CircleCollisionValidator

  def radius
    diameter / 2
  end

  def left
    center_x - radius
  end

  def right
    center_x + radius
  end

  def top
    center_y + radius
  end

  def bottom
    center_y - radius
  end
end
