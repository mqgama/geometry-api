module ApiErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from ActiveRecord::DeleteRestrictionError, with: :delete_restriction_error
    rescue_from ActionController::ParameterMissing, with: :parameter_missing
  end

  private

  def record_not_found(exception)
    render_error(
      message: "Registro não encontrado",
      details: exception.message,
      status: :not_found
    )
  end

  def record_invalid(exception)
    render_error(
      message: "Dados inválidos",
      details: exception.record.errors.full_messages,
      status: :unprocessable_entity
    )
  end

  def delete_restriction_error(exception)
    render_error(
      message: "Não é possível excluir o registro",
      details: "Existem registros associados que impedem a exclusão",
      status: :unprocessable_entity
    )
  end

  def parameter_missing(exception)
    render_error(
      message: "Parâmetro obrigatório ausente",
      details: exception.message,
      status: :bad_request
    )
  end

  def render_error(message:, details:, status:)
    render json: {
      error: {
        message: message,
        details: details,
        timestamp: Time.current.iso8601
      }
    }, status: status
  end
end
