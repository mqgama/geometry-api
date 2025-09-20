require 'swagger_helper'

RSpec.describe Api::V1::SessionsController, type: :request do
  path '/api/v1/sessions' do
    post 'Realiza login do usuário' do
      tags 'Authentication'
      description 'Autentica um usuário e retorna um token JWT'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'login_test@example.com' },
              password: { type: :string, example: 'password123' }
            },
            required: [ 'email', 'password' ]
          }
        },
        required: [ 'user' ]
      }

      response '200', 'Login realizado com sucesso' do
        let(:user) do
          {
            user: {
              email: 'login_test@example.com',
              password: 'password123'
            }
          }
        end

        before do
          create(:user, email: 'login_test@example.com', password: 'password123')
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['data']['user']['data']['attributes']['email']).to eq('login_test@example.com')
          expect(json_response['data']['token']).to be_present
          expect(json_response['meta']['message']).to eq('Login realizado com sucesso')
        end
      end

      response '401', 'Credenciais inválidas' do
        let(:user) do
          {
            user: {
              email: 'login_test@example.com',
              password: 'wrong_password'
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Credenciais inválidas')
        end
      end
    end

    delete 'Realiza logout do usuário' do
      tags 'Authentication'
      description 'Invalida a sessão do usuário atual'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Logout realizado com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }

        run_test! do |response|
          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['meta']['message']).to eq('Logout realizado com sucesso')
        end
      end

      response '401', 'Token inválido' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)
          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Não autorizado')
        end
      end
    end
  end

  path '/api/v1/sessions/current' do
    get 'Obtém informações do usuário atual' do
      tags 'Authentication'
      description 'Retorna as informações do usuário autenticado'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Usuário atual retornado com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['data']['data']['attributes']['email']).to eq(user.email)
        end
      end

      response '401', 'Token inválido' do
        let(:Authorization) { 'Bearer invalid_token' }

        run_test! do |response|
          expect(response).to have_http_status(:unauthorized)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Não autorizado')
        end
      end
    end
  end

  # Mantendo os testes originais para garantir cobertura completa
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
