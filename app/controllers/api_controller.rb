class ApiController < ApplicationController
  include ApiErrorHandler

  before_action :set_content_type

  private

  def set_content_type
    response.headers["Content-Type"] = "application/json"
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
