class FrameSerializer
  include JSONAPI::Serializer

  attributes :center_x, :center_y, :width, :height, :created_at, :updated_at

  attribute :left do |frame|
    frame.left
  end

  attribute :right do |frame|
    frame.right
  end

  attribute :top do |frame|
    frame.top
  end

  attribute :bottom do |frame|
    frame.bottom
  end

  attribute :circles_count do |frame|
    frame.circles.count
  end

  has_many :circles, serializer: CircleSerializer

  attribute :metrics do |frame|
    circles = frame.circles
    if circles.empty?
      {}
    else
      {
        total_circles: circles.count,
        highest_circle: circles.max_by(&:top)&.id,
        lowest_circle: circles.min_by(&:bottom)&.id,
        leftmost_circle: circles.min_by(&:left)&.id,
        rightmost_circle: circles.max_by(&:right)&.id
      }
    end
  end
end
