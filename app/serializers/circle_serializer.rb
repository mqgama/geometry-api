class CircleSerializer
  include JSONAPI::Serializer

  attributes :center_x, :center_y, :diameter, :created_at, :updated_at

  attribute :radius do |circle|
    circle.radius
  end

  attribute :left do |circle|
    circle.left
  end

  attribute :right do |circle|
    circle.right
  end

  attribute :top do |circle|
    circle.top
  end

  attribute :bottom do |circle|
    circle.bottom
  end

  belongs_to :frame, serializer: FrameSerializer
end
