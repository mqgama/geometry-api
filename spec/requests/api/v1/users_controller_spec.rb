require 'swagger_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  path '/api/v1/users' do
    post 'Cria um novo usuário' do
      tags 'Users'
      description 'Registra um novo usuário no sistema e retorna um token JWT'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Test User' },
              email: { type: :string, example: 'test@example.com' },
              password: { type: :string, example: 'password123' },
              password_confirmation: { type: :string, example: 'password123' }
            },
            required: [ 'name', 'email', 'password', 'password_confirmation' ]
          }
        },
        required: [ 'user' ]
      }

      response '201', 'Usuário criado com sucesso' do
        let(:user) do
          {
            user: {
              name: "Test User",
              email: "test@example.com",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)

          json_response = JSON.parse(response.body)
          expect(json_response['data']['user']['data']['attributes']['email']).to eq('test@example.com')
          expect(json_response['data']['token']).to be_present
          expect(json_response['meta']['message']).to eq('Usuário criado com sucesso')
        end
      end

      response '422', 'Dados inválidos' do
        let(:user) do
          {
            user: {
              name: "",
              email: "invalid_email",
              password: "123",
              password_confirmation: "456"
            }
          }
        end

        run_test! do |response|
          post '/api/v1/users', params: user, as: :json

          expect(response).to have_http_status(:unprocessable_content)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Erro ao criar usuário')
          expect(json_response['error']['details']).to be_present
        end
      end
    end
  end

  # Mantendo os testes originais para garantir cobertura completa
  describe 'POST /api/v1/users' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          user: {
            name: "Test User",
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it 'creates a new user' do
        expect {
          post '/api/v1/users', params: valid_params, as: :json
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end

      it 'returns JWT token' do
        post '/api/v1/users', params: valid_params, as: :json

        json_response = JSON.parse(response.body)
        expect(json_response['data']['token']).to be_present
        expect(json_response['meta']['message']).to eq('Usuário criado com sucesso')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          user: {
            name: "",
            email: "invalid_email",
            password: "123",
            password_confirmation: "456"
          }
        }
      end

      it 'returns validation errors' do
        post '/api/v1/users', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['details']).to be_present
      end
    end
  end
end
