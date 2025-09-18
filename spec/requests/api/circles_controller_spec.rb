require 'rails_helper'

RSpec.describe Api::CirclesController, type: :request do
  let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

  describe 'GET /api/circles' do
  before do
    create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 120.0, diameter: 40.0)
  end

    context 'without filters' do
      it 'returns all circles' do
        get '/api/circles', as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(3)
        expect(json_response['meta']['total']).to eq(3)
        expect(json_response['meta']['filters_applied']).to be_empty
      end
    end

    context 'with frame_id filter' do
      let(:other_frame) { create(:frame) }
      before { create(:circle, frame: other_frame) }

      it 'returns circles from specific frame' do
        get "/api/circles?frame_id=#{frame.id}", as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(3)
        expect(json_response['meta']['total']).to eq(3)
        expect(json_response['meta']['filters_applied']).to include("frame_id: #{frame.id}")
      end
    end

    context 'with radius filter' do
      it 'returns circles within radius' do
        get '/api/circles?center_x=100&center_y=100&radius=80', as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data'].length).to eq(2)
        expect(json_response['meta']['total']).to eq(2)
        expect(json_response['meta']['filters_applied']).to include('center_x: 100')
        expect(json_response['meta']['filters_applied']).to include('center_y: 100')
        expect(json_response['meta']['filters_applied']).to include('radius: 80')
      end
    end

    context 'with no matching circles' do
      it 'returns empty result' do
        get '/api/circles?center_x=500&center_y=500&radius=10', as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']).to be_empty
        expect(json_response['meta']['total']).to eq(0)
      end
    end
  end

  describe 'POST /api/frames/:frame_id/circles' do
    context 'with valid parameters' do
      let(:valid_params) do
        {
          circle: {
            center_x: 100.0,
            center_y: 100.0,
            diameter: 50.0
          }
        }
      end

      it 'creates a new circle' do
        expect {
          post "/api/frames/#{frame.id}/circles", params: valid_params, as: :json
        }.to change(Circle, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(100.0)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(100.0)
        expect(json_response['data']['data']['attributes']['diameter']).to eq(50.0)
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
        post "/api/frames/#{frame.id}/circles", params: invalid_params, as: :json

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
        post "/api/frames/#{frame.id}/circles", params: invalid_params, as: :json

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
        post "/api/frames/#{frame.id}/circles", params: colliding_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
        expect(json_response['error']['details']).to include(/Círculo não pode colidir ou encostar em outro círculo/)
      end
    end
  end

  describe 'PUT /api/circles/:id' do
    let(:circle) { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }

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
        put "/api/circles/#{circle.id}", params: valid_params, as: :json

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['data']['data']['attributes']['center_x']).to eq(120.0)
        expect(json_response['data']['data']['attributes']['center_y']).to eq(80.0)
        expect(json_response['data']['data']['attributes']['diameter']).to eq(40.0)
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
        put "/api/circles/#{circle.id}", params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)

        json_response = JSON.parse(response.body)
        expect(json_response['error']['message']).to eq('Dados inválidos')
      end
    end

    context 'when circle does not exist' do
      it 'returns not found error' do
        put '/api/circles/999', params: { circle: { center_x: 100.0 } }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/circles/:id' do
    let(:circle) { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }

    context 'when circle exists' do
      it 'deletes the circle' do
        expect {
          delete "/api/circles/#{circle.id}", as: :json
        }.to change(Circle, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when circle does not exist' do
      it 'returns not found error' do
        delete '/api/circles/999', as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
