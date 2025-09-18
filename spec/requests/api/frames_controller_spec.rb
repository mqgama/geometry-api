require 'rails_helper'

RSpec.describe Api::FramesController, type: :request do
  describe 'POST /api/frames' do
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
          post '/api/frames', params: valid_params, as: :json
        }.to change(Frame, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(100.0)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(100.0)
        expect(json_response['data']['data']['attributes']['width']).to eq(200.0)
        expect(json_response['data']['data']['attributes']['height']).to eq(150.0)
        expect(json_response['meta']['message']).to eq('Frame criado com sucesso')
      end

      it 'creates frame with circles' do
        params_with_circles = valid_params.merge(
          circles: [
            { center_x: 100.0, center_y: 100.0, diameter: 50.0 },
            { center_x: 150.0, center_y: 80.0, diameter: 30.0 }
          ]
        )

        expect {
          post '/api/frames', params: params_with_circles, as: :json
        }.to change(Frame, :count).by(1)
         .and change(Circle, :count).by(2)

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
        post '/api/frames', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include("Center x can't be blank")
        expect(json_response['error']['details']).to include('Width must be greater than 0')
      end

      it 'returns collision error when frames overlap' do
        create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0)

        post '/api/frames', params: {
          frame: {
            center_x: 150.0,
            center_y: 100.0,
            width: 200.0,
            height: 150.0
          }
        }, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include(/Frame não pode colidir ou encostar em outro frame/)
      end
    end
  end

  describe 'GET /api/frames/:id' do
    let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

    context 'when frame exists' do
      before do
        create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
        create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)
      end

      it 'returns frame with metrics' do
        get "/api/frames/#{frame.id}", as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(100.0)
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
        get '/api/frames/999', as: :json

        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Registro não encontrado')
      end
    end
  end

  describe 'DELETE /api/frames/:id' do
    let(:frame) { create(:frame) }

    context 'when frame has no circles' do
      it 'deletes the frame' do
        expect {
          delete "/api/frames/#{frame.id}", as: :json
        }.to change(Frame, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when frame has circles' do
      before { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }

      it 'returns restriction error' do
        expect {
          delete "/api/frames/#{frame.id}", as: :json
        }.not_to change(Frame, :count)

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Não é possível excluir o registro')
      end
    end

    context 'when frame does not exist' do
      it 'returns not found error' do
        delete '/api/frames/999', as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
