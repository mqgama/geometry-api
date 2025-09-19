require 'rails_helper'

RSpec.describe 'API Integration Test', type: :request do
  describe 'POST /api/frames' do
    it 'creates a frame successfully' do
      frame_params = {
        frame: {
          center_x: 100.0,
          center_y: 100.0,
          width: 200.0,
          height: 150.0
        }
      }

      post '/api/v1/frames', params: frame_params, headers: auth_headers, as: :json

      puts "Response status: #{response.status}"
      puts "Response body: #{response.body}"

      expect(response).to have_http_status(:created)
    end
  end
end
