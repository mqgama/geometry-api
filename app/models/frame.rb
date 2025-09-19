class Frame < ApplicationRecord
  has_many :circles, dependent: :restrict_with_exception

  validates :center_x, presence: true
  validates :center_y, presence: true
  validates :width, presence: true, numericality: { greater_than: 0 }
  validates :height, presence: true, numericality: { greater_than: 0 }

  validates_with FrameCollisionValidator

  def left
    center_x - width / 2
  end

  def right
    center_x + width / 2
  end

  def top
    center_y + height / 2
  end

  def bottom
    center_y - height / 2
  end
end
