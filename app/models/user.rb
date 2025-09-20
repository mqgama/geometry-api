class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create

  # JWT token methods
  def generate_jwt_token
    JwtService.encode(user_id: id, email: email)
  end

  def self.find_by_jwt_token(token)
    payload = JwtService.decode(token)
    find(payload["user_id"]) if payload
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    nil
  end
end
