class FrameCreationService
  def initialize(frame_params, circles_params = [])
    @frame_params = frame_params
    @circles_params = circles_params
  end

  def call
    ActiveRecord::Base.transaction do
      frame = Frame.create!(@frame_params)

      if @circles_params.any?
        circles = @circles_params.map do |circle_params|
          frame.circles.build(circle_params)
        end

        circles.each(&:save!)
      end

      frame.reload
    end
  rescue ActiveRecord::RecordInvalid => e
    raise e
  end
end
