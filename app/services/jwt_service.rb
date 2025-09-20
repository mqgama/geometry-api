class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base || "fallback_secret_key_for_development"
  ALGORITHM = "HS256"
  EXPIRATION_TIME = 24.hours

  def self.encode(payload)
    payload[:exp] = EXPIRATION_TIME.from_now.to_i
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded_token = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    decoded_token[0]
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

  def self.valid_token?(token)
    decode(token).present?
  end

  def self.extract_user_id(token)
    payload = decode(token)
    payload&.dig("user_id")
  end
end
