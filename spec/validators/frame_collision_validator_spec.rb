require 'rails_helper'

RSpec.describe FrameCollisionValidator, type: :validator do
  let(:validator) { FrameCollisionValidator.new }

  describe '#validate' do
    context 'when no other frames exist' do
      it 'does not add errors' do
        frame = build(:frame, center_x: 200.0, center_y: 200.0, width: 40.0, height: 20.0)
        validator.validate(frame)
        expect(frame.errors).to be_empty
      end
    end

    context 'when frames do not collide' do
      let!(:frame1) { build(:frame, center_x: 100.0, center_y: 100.0, width: 50.0, height: 30.0) }

      it 'does not add errors for separated frames' do
        frame2 = build(:frame, center_x: 200.0, center_y: 200.0, width: 40.0, height: 20.0)
        validator.validate(frame2)
        expect(frame2.errors).to be_empty
      end

      it 'does not add errors for frames with gap between them' do
        frame2 = build(:frame, center_x: 200.0, center_y: 100.0, width: 40.0, height: 20.0)
        validator.validate(frame2)
        expect(frame2.errors).to be_empty
      end
    end

    context 'when frames collide or touch' do
      let!(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 50.0, height: 30.0) }

    it 'adds error for overlapping frames' do
      frame2 = build(:frame, center_x: 120.0, center_y: 100.0, width: 40.0, height: 20.0)
      validator.validate(frame2)
      expect(frame2.errors[:base]).to include(/Frame não pode colidir ou encostar em outro frame/)
    end

    it 'adds error for touching frames' do
      frame2 = build(:frame, center_x: 145.0, center_y: 100.0, width: 40.0, height: 20.0)
      validator.validate(frame2)
      expect(frame2.errors[:base]).to include(/Frame não pode colidir ou encostar em outro frame/)
    end

    it 'adds error for completely overlapping frames' do
      frame2 = build(:frame, center_x: 100.0, center_y: 100.0, width: 30.0, height: 15.0)
      validator.validate(frame2)
      expect(frame2.errors[:base]).to include(/Frame não pode colidir ou encostar em outro frame/)
    end
    end

    context 'when updating existing frame' do
      let!(:frame1) { create(:frame, center_x: 100.0, center_y: 100.0, width: 50.0, height: 30.0) }

      it 'excludes itself from collision check' do
        frame1.center_x = 150.0
        validator.validate(frame1)
        expect(frame1.errors).to be_empty
      end
    end
  end

  describe '#collides_or_touches?' do
    let(:frame1) { build(:frame, center_x: 100.0, center_y: 100.0, width: 50.0, height: 30.0) }
    let(:frame2) { build(:frame, center_x: 200.0, center_y: 200.0, width: 40.0, height: 20.0) }

    it 'returns false for non-colliding frames' do
      result = validator.send(:collides_or_touches?, frame1, frame2)
      expect(result).to be_falsey
    end

    it 'returns true for colliding frames' do
      frame2.center_x = 120.0
      frame2.center_y = 100.0
      result = validator.send(:collides_or_touches?, frame1, frame2)
      expect(result).to be_truthy
    end

    it 'returns true for touching frames' do
      frame2.center_x = 145.0
      frame2.center_y = 100.0
      result = validator.send(:collides_or_touches?, frame1, frame2)
      expect(result).to be_truthy
    end
  end
end
