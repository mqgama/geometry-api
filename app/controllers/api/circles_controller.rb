class Api::CirclesController < ApiController
  before_action :set_circle, only: [ :update, :destroy ]

  def index
    service = CircleSearchService.new(search_params)
    circles = service.call

    render_success(
      CircleSerializer.new(circles).serializable_hash,
      meta: {
        total: circles.count,
        filters_applied: applied_filters
      }
    )
  end

  def create
    frame = Frame.find(params[:frame_id])
    circle = frame.circles.create!(circle_params)

    render_created(
      CircleSerializer.new(circle).serializable_hash,
      meta: { message: "Círculo criado com sucesso" }
    )
  end

  def update
    @circle.update!(circle_params)

    render_success(
      CircleSerializer.new(@circle).serializable_hash,
      meta: { message: "Círculo atualizado com sucesso" }
    )
  end

  def destroy
    @circle.destroy!
    render_no_content
  end

  private

  def set_circle
    @circle = Circle.find(params[:id])
  end

  def circle_params
    params.require(:circle).permit(:center_x, :center_y, :diameter)
  end

  def search_params
    params.permit(:center_x, :center_y, :radius, :frame_id)
  end

  def applied_filters
    filters = []
    filters << "center_x: #{params[:center_x]}" if params[:center_x].present?
    filters << "center_y: #{params[:center_y]}" if params[:center_y].present?
    filters << "radius: #{params[:radius]}" if params[:radius].present?
    filters << "frame_id: #{params[:frame_id]}" if params[:frame_id].present?
    filters
  end
end
