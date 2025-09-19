require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  describe 'POST /api/v1/sessions' do
    let!(:user) { create(:user, email: 'login_test@example.com', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_params) do
        {
          user: {
            email: 'login_test@example.com',
            password: 'password123'
          }
        }
      end

      it 'returns user and token' do
        post '/api/v1/sessions', params: valid_params, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['user']['data']['attributes']['email']).to eq('login_test@example.com')
        expect(json_response['data']['token']).to be_present
        expect(json_response['meta']['message']).to eq('Login realizado com sucesso')
      end

      it 'returns valid JWT token' do
        post '/api/v1/sessions', params: valid_params, as: :json

        json_response = JSON.parse(response.body)
        token = json_response['data']['token']

        decoded_token = JwtService.decode(token)
        expect(decoded_token['user_id']).to eq(user.id)
        expect(decoded_token['email']).to eq('login_test@example.com')
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          user: {
            email: 'login_test@example.com',
            password: 'wrong_password'
          }
        }
      end

      it 'returns unauthorized error' do
        post '/api/v1/sessions', params: invalid_params, as: :json

        expect(response).to have_http_status(:unauthorized)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Credenciais inválidas')
      end
    end

    context 'with non-existent user' do
      let(:invalid_params) do
        {
          user: {
            email: 'nonexistent@example.com',
            password: 'password123'
          }
        }
      end

      it 'returns unauthorized error' do
        post '/api/v1/sessions', params: invalid_params, as: :json

        expect(response).to have_http_status(:unauthorized)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Credenciais inválidas')
      end
    end
  end

  describe 'GET /api/v1/sessions/current' do
    let(:user) { create(:user) }
    let(:token) { user.generate_jwt_token }

    context 'with valid token' do
      it 'returns current user' do
        get '/api/v1/sessions/current', headers: { 'Authorization' => "Bearer #{token}" }, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['email']).to eq(user.email)
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        get '/api/v1/sessions/current', as: :json

        expect(response).to have_http_status(:unauthorized)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Não autorizado')
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized error' do
        get '/api/v1/sessions/current', headers: { 'Authorization' => 'Bearer invalid_token' }, as: :json

        expect(response).to have_http_status(:unauthorized)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Não autorizado')
      end
    end
  end

  describe 'DELETE /api/v1/sessions' do
    let(:user) { create(:user) }
    let(:token) { user.generate_jwt_token }

    context 'with valid token' do
      it 'returns success message' do
        delete '/api/v1/sessions', headers: { 'Authorization' => "Bearer #{token}" }, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['meta']['message']).to eq('Logout realizado com sucesso')
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        delete '/api/v1/sessions', as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
