class ApiController < ApplicationController
  include ApiErrorHandler

  before_action :set_content_type

  private

  def set_content_type
    response.headers["Content-Type"] = "application/json"
  end

  def authenticate_user!
    token = extract_token_from_header
    return render_unauthorized unless token

    @current_user = User.find_by_jwt_token(token)
    render_unauthorized unless @current_user
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header&.start_with?("Bearer ")

    auth_header.split(" ").last
  end

  def render_unauthorized
    render_error(
      message: "Não autorizado",
      details: "Token JWT inválido ou expirado",
      status: :unauthorized
    )
  end

  def render_success(data, status: :ok, meta: {})
    render json: {
      data: data,
      meta: meta.merge(timestamp: Time.current.iso8601)
    }, status: status
  end

  def render_created(data, meta: {})
    render_success(data, status: :created, meta: meta)
  end

  def render_no_content
    head :no_content
  end
end
