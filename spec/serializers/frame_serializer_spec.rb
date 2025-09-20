require 'rails_helper'

RSpec.describe FrameSerializer do
  let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

  describe 'serialization' do
    it 'includes basic attributes' do
      serialized = FrameSerializer.new(frame).serializable_hash

      expect(serialized[:data][:attributes][:center_x]).to eq(100.0)
      expect(serialized[:data][:attributes][:center_y]).to eq(100.0)
      expect(serialized[:data][:attributes][:width]).to eq(200.0)
      expect(serialized[:data][:attributes][:height]).to eq(150.0)
      expect(serialized[:data][:attributes][:created_at]).to be_present
      expect(serialized[:data][:attributes][:updated_at]).to be_present
    end

    it 'includes calculated boundary attributes' do
      serialized = FrameSerializer.new(frame).serializable_hash

      expect(serialized[:data][:attributes][:left]).to eq(0.0)
      expect(serialized[:data][:attributes][:right]).to eq(200.0)
      expect(serialized[:data][:attributes][:top]).to eq(175.0)
      expect(serialized[:data][:attributes][:bottom]).to eq(25.0)
    end

    it 'includes circles count' do
      create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
      create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)

      serialized = FrameSerializer.new(frame).serializable_hash

      expect(serialized[:data][:attributes][:circles_count]).to eq(2)
    end

    it 'includes relationships' do
      circle = create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)

      serialized = FrameSerializer.new(frame).serializable_hash

      expect(serialized[:data][:relationships][:circles][:data]).to include(
        { id: circle.id.to_s, type: :circle }
      )
    end

    it 'includes metrics when circles exist' do
      circle1 = create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
      circle2 = create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)

      serialized = FrameSerializer.new(frame).serializable_hash
      metrics = serialized[:data][:attributes][:metrics]

      expect(metrics[:total_circles]).to eq(2)
      expect(metrics[:highest_circle]).to eq(circle1.id)
      expect(metrics[:lowest_circle]).to eq(circle2.id)
      expect(metrics[:leftmost_circle]).to eq(circle1.id)
      expect(metrics[:rightmost_circle]).to eq(circle2.id)
    end

    it 'returns empty metrics when no circles exist' do
      serialized = FrameSerializer.new(frame).serializable_hash
      metrics = serialized[:data][:attributes][:metrics]

      expect(metrics).to eq({})
    end
  end
end
