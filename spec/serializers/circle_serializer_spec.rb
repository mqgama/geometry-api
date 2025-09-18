require 'rails_helper'

RSpec.describe CircleSerializer do
  let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }
  let(:circle) { create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0) }

  describe 'serialization' do
    it 'includes basic attributes' do
      serialized = CircleSerializer.new(circle).serializable_hash

      expect(serialized[:data][:attributes][:center_x]).to eq(100.0)
      expect(serialized[:data][:attributes][:center_y]).to eq(100.0)
      expect(serialized[:data][:attributes][:diameter]).to eq(50.0)
      expect(serialized[:data][:attributes][:created_at]).to be_present
      expect(serialized[:data][:attributes][:updated_at]).to be_present
    end

    it 'includes calculated attributes' do
      serialized = CircleSerializer.new(circle).serializable_hash

      expect(serialized[:data][:attributes][:radius]).to eq(25.0)
      expect(serialized[:data][:attributes][:left]).to eq(75.0)
      expect(serialized[:data][:attributes][:right]).to eq(125.0)
      expect(serialized[:data][:attributes][:top]).to eq(125.0)
      expect(serialized[:data][:attributes][:bottom]).to eq(75.0)
    end

    it 'includes frame relationship' do
      serialized = CircleSerializer.new(circle).serializable_hash

      expect(serialized[:data][:relationships][:frame][:data]).to eq(
        { id: frame.id.to_s, type: :frame }
      )
    end
  end
end
