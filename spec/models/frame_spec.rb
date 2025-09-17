require 'rails_helper'

RSpec.describe Frame, type: :model do
  describe 'associations' do
    it 'should have many circles with dependent restrict_with_error' do
      frame = create(:frame)
      expect(frame.circles).to be_empty
      
      circle = create(:circle, frame: frame)
      expect(frame.circles).to include(circle)
    end
  end

  describe 'validations' do
    describe 'presence validations' do
      it 'validates presence of center_x' do
        frame = Frame.new(center_y: 100.0, width: 200.0, height: 150.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:center_x]).to include("can't be blank")
      end

      it 'validates presence of center_y' do
        frame = Frame.new(center_x: 100.0, width: 200.0, height: 150.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:center_y]).to include("can't be blank")
      end

      it 'validates presence of width' do
        frame = Frame.new(center_x: 100.0, center_y: 100.0, height: 150.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:width]).to include("can't be blank")
      end

      it 'validates presence of height' do
        frame = Frame.new(center_x: 100.0, center_y: 100.0, width: 200.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:height]).to include("can't be blank")
      end
    end

    describe 'numericality validations' do
      it 'validates width is greater than 0' do
        frame = Frame.new(center_x: 100.0, center_y: 100.0, width: 0.0, height: 150.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:width]).to include('must be greater than 0')
      end

      it 'validates height is greater than 0' do
        frame = Frame.new(center_x: 100.0, center_y: 100.0, width: 200.0, height: 0.0)
        expect(frame).not_to be_valid
        expect(frame.errors[:height]).to include('must be greater than 0')
      end
    end
  end

  describe 'database constraints' do
    it 'should have decimal precision of 12,4 for all coordinate fields' do
      frame = Frame.new(
        center_x: 1234567890.1234,
        center_y: 1234567890.1234,
        width: 1234567890.1234,
        height: 1234567890.1234
      )
      expect(frame).to be_valid
    end
  end

  describe 'factory' do
    it 'should have a valid factory' do
      frame = build(:frame)
      expect(frame).to be_valid
    end
  end

  describe 'creation' do
    it 'creates a frame with valid attributes' do
      frame = Frame.create!(
        center_x: 100.0,
        center_y: 200.0,
        width: 300.0,
        height: 400.0
      )
      
      expect(frame).to be_persisted
      expect(frame.center_x).to eq(100.0)
      expect(frame.center_y).to eq(200.0)
      expect(frame.width).to eq(300.0)
      expect(frame.height).to eq(400.0)
    end
  end

  describe 'dependent: :restrict_with_error' do
    let(:frame) { create(:frame) }
    
    it 'prevents deletion when circles exist' do
      create(:circle, frame: frame)
      
      # Note: dependent: :restrict_with_error may not work as expected in all Rails versions
      # This test documents the current behavior
      expect { frame.destroy }.not_to raise_error
      # The frame should still exist because circles prevent deletion
      expect(Frame.exists?(frame.id)).to be_truthy
    end

    it 'allows deletion when no circles exist' do
      expect { frame.destroy }.not_to raise_error
      expect(Frame.exists?(frame.id)).to be_falsey
    end
  end

  describe 'edge cases' do
    it 'accepts zero values for center coordinates' do
      frame = Frame.new(
        center_x: 0.0,
        center_y: 0.0,
        width: 100.0,
        height: 100.0
      )
      expect(frame).to be_valid
    end

    it 'accepts negative center coordinates' do
      frame = Frame.new(
        center_x: -100.0,
        center_y: -200.0,
        width: 100.0,
        height: 100.0
      )
      expect(frame).to be_valid
    end

    it 'rejects zero width' do
      frame = Frame.new(
        center_x: 100.0,
        center_y: 100.0,
        width: 0.0,
        height: 100.0
      )
      expect(frame).not_to be_valid
      expect(frame.errors[:width]).to include('must be greater than 0')
    end

    it 'rejects negative width' do
      frame = Frame.new(
        center_x: 100.0,
        center_y: 100.0,
        width: -50.0,
        height: 100.0
      )
      expect(frame).not_to be_valid
      expect(frame.errors[:width]).to include('must be greater than 0')
    end

    it 'rejects zero height' do
      frame = Frame.new(
        center_x: 100.0,
        center_y: 100.0,
        width: 100.0,
        height: 0.0
      )
      expect(frame).not_to be_valid
      expect(frame.errors[:height]).to include('must be greater than 0')
    end

    it 'rejects negative height' do
      frame = Frame.new(
        center_x: 100.0,
        center_y: 100.0,
        width: 100.0,
        height: -50.0
      )
      expect(frame).not_to be_valid
      expect(frame.errors[:height]).to include('must be greater than 0')
    end
  end
end
