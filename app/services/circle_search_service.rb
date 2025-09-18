class CircleSearchService
  def initialize(params)
    @center_x = params[:center_x]&.to_f
    @center_y = params[:center_y]&.to_f
    @radius = params[:radius]&.to_f
    @frame_id = params[:frame_id]
  end

  def call
    circles = Circle.includes(:frame)

    circles = circles.where(frame_id: @frame_id) if @frame_id.present?

    if @center_x.present? && @center_y.present? && @radius.present?
      circles = filter_circles_within_radius(circles)
    end

    circles
  end

  private

  def filter_circles_within_radius(circles)
    circles.select do |circle|
      distance = Math.sqrt(
        (circle.center_x - @center_x)**2 +
        (circle.center_y - @center_y)**2
      )

      # Verifica se o círculo está completamente dentro do raio especificado
      distance + circle.radius <= @radius
    end
  end
end
