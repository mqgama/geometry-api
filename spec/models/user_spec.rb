require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'requires email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires unique email' do
      create(:user, email: 'unique_test@example.com')
      user = build(:user, email: 'unique_test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it 'requires valid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("is invalid")
    end

    it 'requires name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'requires name with minimum length' do
      user = build(:user, name: 'A')
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("is too short (minimum is 2 characters)")
    end

    it 'requires name with maximum length' do
      user = build(:user, name: 'A' * 101)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("is too long (maximum is 100 characters)")
    end

    it 'requires password on creation' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'requires password with minimum length' do
      user = build(:user, password: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it 'requires password confirmation on creation' do
      user = build(:user, password_confirmation: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("can't be blank")
    end
  end

  describe 'JWT token methods' do
    let(:user) { create(:user) }

    it 'generates JWT token' do
      token = user.generate_jwt_token
      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it 'finds user by JWT token' do
      token = user.generate_jwt_token
      found_user = User.find_by_jwt_token(token)
      expect(found_user).to eq(user)
    end

    it 'returns nil for invalid token' do
      found_user = User.find_by_jwt_token('invalid_token')
      expect(found_user).to be_nil
    end

    it 'returns nil for expired token' do
      # Create a token with past expiration
      payload = { user_id: user.id, email: user.email, exp: 1.hour.ago.to_i }
      expired_token = JWT.encode(payload, JwtService::SECRET_KEY, JwtService::ALGORITHM)

      found_user = User.find_by_jwt_token(expired_token)
      expect(found_user).to be_nil
    end
  end

  describe 'password security' do
    it 'hashes password' do
      user = create(:user, password: 'password123')
      expect(user.password_digest).not_to eq('password123')
      expect(user.password_digest).to be_present
    end

    it 'authenticates with correct password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      user = create(:user, password: 'password123')
      expect(user.authenticate('wrong_password')).to be_falsey
    end
  end
end
