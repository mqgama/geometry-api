class Api::FramesController < ApiController
  before_action :set_frame, only: [ :show, :destroy ]

  def create
    frame_params = frame_creation_params
    circles_params = params[:circles] || []

    service = FrameCreationService.new(frame_params, circles_params)
    frame = service.call

    render_created(
      FrameSerializer.new(frame).serializable_hash,
      meta: { message: "Frame criado com sucesso" }
    )
  end

  def show
    render_success(
      FrameSerializer.new(@frame).serializable_hash
    )
  end

  def destroy
    @frame.destroy!
    render_no_content
  end

  private

  def set_frame
    @frame = Frame.find(params[:id])
  end

  def frame_creation_params
    params.require(:frame).permit(:center_x, :center_y, :width, :height)
  end
end
