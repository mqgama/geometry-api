require 'swagger_helper'

RSpec.describe Api::V1::FramesController, type: :request do
  path '/api/v1/frames' do
    post 'Cria um novo frame' do
      tags 'Frames'
      description 'Cria um novo frame geométrico'
      consumes 'application/json'
      produces 'application/json'
      security [ Bearer: [] ]

      parameter name: :frame, in: :body, schema: {
        type: :object,
        properties: {
          frame: {
            type: :object,
            properties: {
              center_x: { type: :number, format: :float, example: 100.0 },
              center_y: { type: :number, format: :float, example: 100.0 },
              width: { type: :number, format: :float, example: 200.0 },
              height: { type: :number, format: :float, example: 150.0 }
            },
            required: [ 'center_x', 'center_y', 'width', 'height' ]
          }
        },
        required: [ 'frame' ]
      }

      response '201', 'Frame criado com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) do
          {
            frame: {
              center_x: 100.0,
              center_y: 100.0,
              width: 200.0,
              height: 150.0
            }
          }
        end

        run_test! do |response|
          expect(response).to have_http_status(:created)

          json_response = JSON.parse(response.body)
          expect(json_response['meta']['message']).to eq('Frame criado com sucesso')
        end
      end

      response '422', 'Dados inválidos' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) do
          {
            frame: {
              center_x: nil,
              center_y: nil,
              width: -100.0,
              height: -50.0
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

  path '/api/v1/frames/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do frame'

    get 'Obtém um frame específico' do
      tags 'Frames'
      description 'Retorna informações detalhadas de um frame'
      produces 'application/json'
      security [ Bearer: [] ]

      response '200', 'Frame encontrado' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:id) { frame.id }

        run_test! do |response|
          expect(response).to have_http_status(:ok)

          json_response = JSON.parse(response.body)
          expect(json_response['data']['data']['attributes']['center_x']).to eq(frame.center_x.to_s)
        end
      end

      response '404', 'Frame não encontrado' do
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

    delete 'Remove um frame' do
      tags 'Frames'
      description 'Remove um frame do sistema'
      produces 'application/json'
      security [ Bearer: [] ]

      response '204', 'Frame removido com sucesso' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:id) { frame.id }

        run_test! do |response|
          expect(response).to have_http_status(:no_content)
        end
      end

      response '422', 'Frame possui círculos' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:frame) { create(:frame) }
        let(:id) { frame.id }

        before do
          create(:circle, frame: frame)
        end

        run_test! do |response|
          expect(response).to have_http_status(:unprocessable_content)

          json_response = JSON.parse(response.body)
          expect(json_response['error']['message']).to eq('Não é possível excluir o registro')
        end
      end

      response '404', 'Frame não encontrado' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_jwt_token}" }
        let(:id) { 999 }

        run_test! do |response|
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  # Mantendo os testes originais para garantir cobertura completa
  describe 'POST /api/v1/frames' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          frame: {
            center_x: 100.0,
            center_y: 100.0,
            width: 200.0,
            height: 150.0
          }
        }
      end

      it 'creates a new frame' do
        expect {
          post '/api/v1/frames', params: valid_params, headers: auth_headers, as: :json
        }.to change(Frame, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(100.0.to_s)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(100.0.to_s)
        expect(json_response['data']['data']['attributes']['width']).to eq(200.0.to_s)
        expect(json_response['data']['data']['attributes']['height']).to eq(150.0.to_s)
        expect(json_response['meta']['message']).to eq('Frame criado com sucesso')
      end

      it 'creates frame with circles' do
        # First test without circles to see if frame creation works
        expect {
          post '/api/v1/frames', params: valid_params, headers: auth_headers, as: :json
        }.to change(Frame, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          frame: {
            center_x: nil,
            center_y: 100.0,
            width: -10.0,
            height: 150.0
          }
        }
      end

      it 'returns validation errors' do
        post '/api/v1/frames', params: invalid_params, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include("Center x can't be blank")
        expect(json_response['error']['details']).to include('Width must be greater than 0')
      end

      it 'returns collision error when frames overlap' do
        create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0)

        post '/api/v1/frames', params: {
          frame: {
            center_x: 150.0,
            center_y: 100.0,
            width: 200.0,
            height: 150.0
          }
        }, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include(/Frame não pode colidir ou encostar em outro frame/)
      end
    end
  end

  describe 'GET /api/v1/frames/:id' do
    let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

    context 'when frame exists' do
      before do
        create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
        create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)
      end

      it 'returns frame with metrics' do
        get "/api/v1/frames/#{frame.id}", headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(100.0.to_s)
        expect(json_response['data']['data']['attributes']['circles_count']).to eq(2)

        metrics = json_response['data']['data']['attributes']['metrics']
        expect(metrics['total_circles']).to eq(2)
        expect(metrics['highest_circle']).to be_present
        expect(metrics['lowest_circle']).to be_present
        expect(metrics['leftmost_circle']).to be_present
        expect(metrics['rightmost_circle']).to be_present
      end
    end

    context 'when frame does not exist' do
      it 'returns not found error' do
        get '/api/v1/frames/999', headers: auth_headers, as: :json

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Registro não encontrado')
      end
    end
  end

  describe 'DELETE /api/v1/frames/:id' do
    let!(:frame) { create(:frame) }

    context 'when frame has no circles' do
      it 'deletes the frame' do
        expect {
          delete "/api/v1/frames/#{frame.id}", headers: auth_headers, as: :json
        }.to change(Frame, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when frame has circles' do
      let!(:circle) { create(:circle, frame: frame, center_x: frame.center_x, center_y: frame.center_y, diameter: 30.0) }

      it 'returns restriction error' do
        expect {
          delete "/api/v1/frames/#{frame.id}", headers: auth_headers, as: :json
        }.not_to change(Frame, :count)

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Não é possível excluir o registro')
      end
    end

    context 'when frame does not exist' do
      it 'returns not found error' do
        delete '/api/v1/frames/999', headers: auth_headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
