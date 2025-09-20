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
    # Use SQL to filter circles within radius for better performance and Kaminari compatibility
    circles.where(
      "SQRT(POWER(center_x - ?, 2) + POWER(center_y - ?, 2)) + (diameter / 2) <= ?",
      @center_x, @center_y, @radius
    )
  end
end
