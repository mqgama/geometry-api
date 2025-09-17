require 'rails_helper'

RSpec.describe Circle, type: :model do
  describe 'associations' do
    it 'should belong to frame' do
      frame = create(:frame)
      circle = create(:circle, frame: frame)
      expect(circle.frame).to eq(frame)
    end
  end

  describe 'validations' do
    describe 'presence validations' do
      it 'validates presence of center_x' do
        frame = create(:frame)
        circle = Circle.new(frame: frame, center_y: 100.0, diameter: 50.0)
        expect(circle).not_to be_valid
        expect(circle.errors[:center_x]).to include("can't be blank")
      end

      it 'validates presence of center_y' do
        frame = create(:frame)
        circle = Circle.new(frame: frame, center_x: 100.0, diameter: 50.0)
        expect(circle).not_to be_valid
        expect(circle.errors[:center_y]).to include("can't be blank")
      end

      it 'validates presence of diameter' do
        frame = create(:frame)
        circle = Circle.new(frame: frame, center_x: 100.0, center_y: 100.0)
        expect(circle).not_to be_valid
        expect(circle.errors[:diameter]).to include("can't be blank")
      end
    end

    describe 'numericality validations' do
      it 'validates diameter is greater than 0' do
        frame = create(:frame)
        circle = Circle.new(frame: frame, center_x: 100.0, center_y: 100.0, diameter: 0.0)
        expect(circle).not_to be_valid
        expect(circle.errors[:diameter]).to include('must be greater than 0')
      end
    end
  end

  describe 'database constraints' do
    it 'should have decimal precision of 12,4 for all coordinate fields' do
      frame = create(:frame)
      circle = Circle.new(
        frame: frame,
        center_x: 1234567890.1234,
        center_y: 1234567890.1234,
        diameter: 1234567890.1234
      )
      expect(circle).to be_valid
    end

    it 'should require a frame' do
      circle = Circle.new(
        center_x: 100.0,
        center_y: 100.0,
        diameter: 50.0
      )
      expect(circle).not_to be_valid
      expect(circle.errors[:frame]).to include('must exist')
    end
  end

  describe 'factory' do
    it 'should have a valid factory' do
      circle = build(:circle)
      expect(circle).to be_valid
    end
  end

  describe 'creation' do
    let(:frame) { create(:frame) }

    it 'creates a circle with valid attributes' do
      circle = Circle.create!(
        frame: frame,
        center_x: 100.0,
        center_y: 200.0,
        diameter: 50.0
      )
      
      expect(circle).to be_persisted
      expect(circle.frame).to eq(frame)
      expect(circle.center_x).to eq(100.0)
      expect(circle.center_y).to eq(200.0)
      expect(circle.diameter).to eq(50.0)
    end
  end

  describe 'foreign key constraint' do
    it 'prevents creation with non-existent frame_id' do
      expect {
        Circle.create!(
          frame_id: 99999, # non-existent ID
          center_x: 100.0,
          center_y: 100.0,
          diameter: 50.0
        )
      }.to raise_error(ActiveRecord::RecordInvalid, /Frame must exist/)
    end
  end

  describe 'edge cases' do
    let(:frame) { create(:frame) }

    it 'accepts zero values for center coordinates' do
      circle = Circle.new(
        frame: frame,
        center_x: 0.0,
        center_y: 0.0,
        diameter: 50.0
      )
      expect(circle).to be_valid
    end

    it 'accepts negative center coordinates' do
      circle = Circle.new(
        frame: frame,
        center_x: -100.0,
        center_y: -200.0,
        diameter: 50.0
      )
      expect(circle).to be_valid
    end

    it 'rejects zero diameter' do
      circle = Circle.new(
        frame: frame,
        center_x: 100.0,
        center_y: 100.0,
        diameter: 0.0
      )
      expect(circle).not_to be_valid
      expect(circle.errors[:diameter]).to include('must be greater than 0')
    end

    it 'rejects negative diameter' do
      circle = Circle.new(
        frame: frame,
        center_x: 100.0,
        center_y: 100.0,
        diameter: -50.0
      )
      expect(circle).not_to be_valid
      expect(circle.errors[:diameter]).to include('must be greater than 0')
    end

    it 'accepts very small diameter' do
      circle = Circle.new(
        frame: frame,
        center_x: 100.0,
        center_y: 100.0,
        diameter: 0.0001
      )
      expect(circle).to be_valid
    end

    it 'accepts very large diameter' do
      circle = Circle.new(
        frame: frame,
        center_x: 100.0,
        center_y: 100.0,
        diameter: 999999.9999
      )
      expect(circle).to be_valid
    end
  end

  describe 'relationship with frame' do
    let(:frame) { create(:frame) }

    it 'belongs to the correct frame' do
      circle = create(:circle, frame: frame)
      expect(circle.frame).to eq(frame)
      expect(frame.circles).to include(circle)
    end

    it 'can have multiple circles in the same frame' do
      circle1 = create(:circle, frame: frame)
      circle2 = create(:circle, frame: frame)
      
      expect(frame.circles.count).to eq(2)
      expect(frame.circles).to include(circle1, circle2)
    end
  end

  describe 'deletion behavior' do
    let(:frame) { create(:frame) }
    let(:circle) { create(:circle, frame: frame) }

    it 'can be deleted independently' do
      expect { circle.destroy }.not_to raise_error
      expect(Circle.exists?(circle.id)).to be_falsey
    end

    it 'does not affect the frame when deleted' do
      circle.destroy
      expect(Frame.exists?(frame.id)).to be_truthy
    end
  end
end
