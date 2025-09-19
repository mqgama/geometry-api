require 'rails_helper'

RSpec.describe JwtService, type: :service do
  let(:payload) { { user_id: 1, email: 'test@example.com' } }

  describe '.encode' do
    it 'generates a valid JWT token' do
      token = described_class.encode(payload)
      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it 'includes expiration time' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded['exp']).to be_present
      expect(decoded['exp']).to be > Time.current.to_i
    end

    it 'includes original payload' do
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded['user_id']).to eq(payload[:user_id])
      expect(decoded['email']).to eq(payload[:email])
    end
  end

  describe '.decode' do
    let(:token) { described_class.encode(payload) }

    it 'decodes valid token' do
      decoded = described_class.decode(token)
      expect(decoded).to be_present
      expect(decoded['user_id']).to eq(payload[:user_id])
    end

    it 'returns nil for invalid token' do
      decoded = described_class.decode('invalid_token')
      expect(decoded).to be_nil
    end

    it 'returns nil for expired token' do
      expired_payload = payload.merge(exp: 1.hour.ago.to_i)
      expired_token = JWT.encode(expired_payload, JwtService::SECRET_KEY, JwtService::ALGORITHM)

      decoded = described_class.decode(expired_token)
      expect(decoded).to be_nil
    end
  end

  describe '.valid_token?' do
    let(:token) { described_class.encode(payload) }

    it 'returns true for valid token' do
      expect(described_class.valid_token?(token)).to be_truthy
    end

    it 'returns false for invalid token' do
      expect(described_class.valid_token?('invalid_token')).to be_falsey
    end

    it 'returns false for expired token' do
      expired_payload = payload.merge(exp: 1.hour.ago.to_i)
      expired_token = JWT.encode(expired_payload, JwtService::SECRET_KEY, JwtService::ALGORITHM)

      expect(described_class.valid_token?(expired_token)).to be_falsey
    end
  end

  describe '.extract_user_id' do
    let(:token) { described_class.encode(payload) }

    it 'extracts user_id from valid token' do
      user_id = described_class.extract_user_id(token)
      expect(user_id).to eq(payload[:user_id])
    end

    it 'returns nil for invalid token' do
      user_id = described_class.extract_user_id('invalid_token')
      expect(user_id).to be_nil
    end
  end
end
