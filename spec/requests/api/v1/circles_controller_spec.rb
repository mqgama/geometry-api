require 'swagger_helper'

RSpec.describe Api::V1::CirclesController, type: :request do
  path '/api/v1/circles' do
    get 'Lista todos os círculos' do
      tags 'Circles'
      description 'Retorna uma lista de círculos com filtros opcionais'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :frame_id, in: :query, type: :integer, required: false, description: 'ID do frame'
      parameter name: :center_x, in: :query, type: :number, required: false, description: 'Coordenada X do centro'
      parameter name: :center_y, in: :query, type: :number, required: false, description: 'Coordenada Y do centro'
      parameter name: :radius, in: :query, type: :number, required: false, description: 'Raio de busca'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Número da página (padrão: 1)'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Itens por página (padrão: 20, máximo: 100)'

      response '200', 'Lista de círculos retornada com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }

        before do
          create(:circle, frame: frame)
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['data']['data']).to be_an(Array)
          expect(json_response['meta']).to include('total', 'total_pages', 'current_page', 'per_page')
        end
      end
    end
  end

  path '/api/v1/frames/{frame_id}/circles' do
    parameter name: :frame_id, in: :path, type: :integer, description: 'ID do frame'

    post 'Cria um novo círculo em um frame' do
      tags 'Circles'
      description 'Adiciona um novo círculo a um frame específico'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              center_x: { type: :number, format: :float, example: 100.0 },
              center_y: { type: :number, format: :float, example: 100.0 },
              diameter: { type: :number, format: :float, example: 50.0 }
            },
            required: [ 'center_x', 'center_y', 'diameter' ]
          }
        },
        required: [ 'circle' ]
      }

      response '201', 'Círculo criado com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:frame_id) { frame.id }
        let(:circle) do
          {
            circle: {
              center_x: frame.center_x,
              center_y: frame.center_y,
              diameter: 50.0
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)

          json_response = JSON.parse(response.body)
          expect(json_response['meta']['message']).to eq('Círculo criado com sucesso')
        end
      end

      response '422', 'Dados inválidos' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:frame_id) { frame.id }
        let(:circle) do
          {
            circle: {
              center_x: nil,
              center_y: nil,
              diameter: -10.0
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_content)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['details']).to be_present
        end
      end
    end
  end

  path '/api/v1/circles/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do círculo'

    put 'Atualiza um círculo' do
      tags 'Circles'
      description 'Atualiza as propriedades de um círculo existente'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :circle, in: :body, schema: {
        type: :object,
        properties: {
          circle: {
            type: :object,
            properties: {
              center_x: { type: :number, format: :float, example: 100.0 },
              center_y: { type: :number, format: :float, example: 100.0 },
              diameter: { type: :number, format: :float, example: 50.0 }
            }
          }
        },
        required: [ 'circle' ]
      }

      response '200', 'Círculo atualizado com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:circle_obj) { create(:circle, frame: frame) }
        let(:id) { circle_obj.id }
        let(:circle) do
          {
            circle: {
              center_x: frame.center_x + 10,
              center_y: frame.center_y + 10,
              diameter: 60.0
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['meta']['message']).to eq('Círculo atualizado com sucesso')
        end
      end

      response '404', 'Círculo não encontrado' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:id) { 999 }
        let(:circle) do
          {
            circle: {
              center_x: 100.0,
              center_y: 100.0,
              diameter: 50.0
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:not_found)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Registro não encontrado')
        end
      end
    end

    delete 'Remove um círculo' do
      tags 'Circles'
      description 'Remove um círculo do sistema'
      produces 'application/json'
      security [ Bearer: [] ]

      response '204', 'Círculo removido com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:circle_obj) { create(:circle, frame: frame) }
        let(:id) { circle_obj.id }

        run_test! do |response|
          expect(response).to have_http_status(:no_content)
        end
      end

      response '404', 'Círculo não encontrado' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:id) { 999 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Registro não encontrado')
        end
      end
    end
  end

  # Mantendo os testes originais para garantir cobertura completa
  let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }
  let(:large_frame) { create(:frame, center_x: 5000.0, center_y: 5000.0, width: 2000.0, height: 2000.0) }

  describe 'GET /api/v1/circles' do
  before do
    create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 120.0, diameter: 40.0)
  end

    context 'without filters' do
      it 'returns all circles' do
        get '/api/v1/circles', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(3)
        expect(json_response['meta']['total']).to eq(3)
        expect(json_response['meta']['filters_applied']).to be_empty
      end
    end

    context 'with pagination' do
      before do
        # Create more circles to test pagination using FactoryBot
        # Using large frame with small circles well spaced apart
        # Frame limits: left: 4000, right: 6000, top: 6000, bottom: 4000
        7.times do |i|
          create(:circle, frame: large_frame, center_x: 4100.0 + i * 100, center_y: 4100.0 + i * 100, diameter: 20.0)
        end
      end

      it 'returns paginated results with default per_page' do
        get '/api/v1/circles', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(10) # 3 original + 7 new circles
        expect(json_response['meta']['total']).to eq(10)
        expect(json_response['meta']['current_page']).to eq(1)
        expect(json_response['meta']['per_page']).to eq(20)
        expect(json_response['meta']['total_pages']).to eq(1)
      end

      it 'returns paginated results with custom per_page' do
        get '/api/v1/circles?per_page=5', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(5)
        expect(json_response['meta']['total']).to eq(10)
        expect(json_response['meta']['current_page']).to eq(1)
        expect(json_response['meta']['per_page']).to eq(5)
        expect(json_response['meta']['total_pages']).to eq(2)
        expect(json_response['meta']['next_page']).to eq(2)
        expect(json_response['meta']['prev_page']).to be_nil
      end

      it 'returns second page results' do
        get '/api/v1/circles?page=2&per_page=5', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(5)
        expect(json_response['meta']['total']).to eq(10)
        expect(json_response['meta']['current_page']).to eq(2)
        expect(json_response['meta']['per_page']).to eq(5)
        expect(json_response['meta']['total_pages']).to eq(2)
        expect(json_response['meta']['next_page']).to be_nil
        expect(json_response['meta']['prev_page']).to eq(1)
      end

      it 'respects maximum per_page limit' do
        get '/api/v1/circles?per_page=200', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['meta']['per_page']).to eq(100) # max limit
      end
    end

    context 'with frame_id filter' do
      let(:other_frame) { create(:frame) }
      before { create(:circle, frame: other_frame) }

      it 'returns circles from specific frame' do
        get "/api/v1/circles?frame_id=#{frame.id}", headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(3)
        expect(json_response['meta']['total']).to eq(3)
        expect(json_response['meta']['filters_applied']).to include("frame_id: #{frame.id}")
      end
    end

    context 'with radius filter' do
      it 'returns circles within radius' do
        get '/api/v1/circles?center_x=100&center_y=100&radius=70', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(2)
        expect(json_response['meta']['total']).to eq(2)
        expect(json_response['meta']['filters_applied']).to include('center_x: 100')
        expect(json_response['meta']['filters_applied']).to include('center_y: 100')
        expect(json_response['meta']['filters_applied']).to include('radius: 70')
      end
    end

    context 'with no matching circles' do
      it 'returns empty result' do
        get '/api/v1/circles?center_x=500&center_y=500&radius=10', headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']).to be_empty
        expect(json_response['meta']['total']).to eq(0)
      end
    end
  end

  describe 'POST /api/v1/frames/:frame_id/circles' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          circle: {
            center_x: frame.center_x,
            center_y: frame.center_y,
            diameter: 50.0
          }
        }
      end

      it 'creates a new circle' do
        expect {
          post "/api/v1/frames/#{frame.id}/circles", params: valid_params, headers: auth_headers, as: :json
        }.to change(Circle, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(frame.center_x.to_s)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(frame.center_y.to_s)
        expect(json_response['data']['data']['attributes']['diameter']).to eq(50.0.to_s)
        expect(json_response['meta']['message']).to eq('Círculo criado com sucesso')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          circle: {
            center_x: nil,
            center_y: 100.0,
            diameter: -10.0
          }
        }
      end

      it 'returns validation errors' do
        post "/api/v1/frames/#{frame.id}/circles", params: invalid_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include("Center x can't be blank")
        expect(json_response['error']['details']).to include('Diameter must be greater than 0')
      end
    end

    context 'when circle extends beyond frame' do
      let(:invalid_params) do
        {
          circle: {
            center_x: 50.0,
            center_y: 50.0,
            diameter: 200.0
          }
        }
      end

      it 'returns boundary error' do
        post "/api/v1/frames/#{frame.id}/circles", params: invalid_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include(/Círculo se estende além do limite/)
      end
    end

    context 'when circles collide' do
      before { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }

      let(:colliding_params) do
        {
          circle: {
            center_x: 110.0,
            center_y: 100.0,
            diameter: 50.0
          }
        }
      end

      it 'returns collision error' do
        post "/api/v1/frames/#{frame.id}/circles", params: colliding_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include(/Círculo não pode colidir ou encostar em outro círculo/)
      end
    end
  end

  describe 'PUT /api/v1/circles/:id' do
    let(:circle) { create(:circle, frame: frame, center_x: frame.center_x, center_y: frame.center_y, diameter: 50.0) }

    context 'with valid parameters' do
      let(:valid_params) do
        {
          circle: {
            center_x: 120.0,
            center_y: 80.0,
            diameter: 40.0
          }
        }
      end

      it 'updates the circle' do
        put "/api/v1/circles/#{circle.id}", params: valid_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(120.0.to_s)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(80.0.to_s)
        expect(json_response['data']['data']['attributes']['diameter']).to eq(40.0.to_s)
        expect(json_response['meta']['message']).to eq('Círculo atualizado com sucesso')

        circle.reload
        expect(circle.center_x).to eq(120.0)
        expect(circle.center_y).to eq(80.0)
        expect(circle.diameter).to eq(40.0)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          circle: {
            center_x: nil,
            center_y: 100.0,
            diameter: -10.0
          }
        }
      end

      it 'returns validation errors' do
        put "/api/v1/circles/#{circle.id}", params: invalid_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
      end
    end

    context 'when circle does not exist' do
      it 'returns not found error' do
        put '/api/v1/circles/999', params: { circle: { center_x: 100.0 } }, headers: auth_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/circles/:id' do
    let!(:circle) { create(:circle, frame: frame, center_x: frame.center_x, center_y: frame.center_y, diameter: 30.0) }

    context 'when circle exists' do
      it 'deletes the circle' do
        expect {
          delete "/api/v1/circles/#{circle.id}", headers: auth_headers, as: :json
        }.to change(Circle, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when circle does not exist' do
      it 'returns not found error' do
        delete '/api/v1/circles/999', headers: auth_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
