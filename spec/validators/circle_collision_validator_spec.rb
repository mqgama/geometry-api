require 'rails_helper'

RSpec.describe CircleCollisionValidator, type: :validator do
  let(:validator) { CircleCollisionValidator.new }

  describe '#validate' do
    context 'when circle fits within frame' do
      let!(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

      it 'does not add errors for circle inside frame' do
        circle = build(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
        validator.validate(circle)
        expect(circle.errors).to be_empty
      end

      it 'does not add errors for circle touching frame boundaries' do
        circle = build(:circle, frame: frame, center_x: 25.0, center_y: 50.0, diameter: 50.0)
        validator.validate(circle)
        expect(circle.errors).to be_empty
      end
    end

    context 'when circle extends beyond frame boundaries' do
      let!(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

    it 'adds error for circle extending beyond left boundary' do
      circle = build(:circle, frame: frame, center_x: -10.0, center_y: 100.0, diameter: 50.0)
      validator.validate(circle)
      expect(circle.errors[:center_x]).to include('Círculo se estende além do limite esquerdo do frame')
    end

    it 'adds error for circle extending beyond right boundary' do
      circle = build(:circle, frame: frame, center_x: 210.0, center_y: 100.0, diameter: 50.0)
      validator.validate(circle)
      expect(circle.errors[:center_x]).to include('Círculo se estende além do limite direito do frame')
    end

    it 'adds error for circle extending beyond top boundary' do
      circle = build(:circle, frame: frame, center_x: 100.0, center_y: 200.0, diameter: 50.0)
      validator.validate(circle)
      expect(circle.errors[:center_y]).to include('Círculo se estende além do limite superior do frame')
    end

    it 'adds error for circle extending beyond bottom boundary' do
      circle = build(:circle, frame: frame, center_x: 100.0, center_y: -25.0, diameter: 50.0)
      validator.validate(circle)
      expect(circle.errors[:center_y]).to include('Círculo se estende além do limite inferior do frame')
    end
    end

    context 'when circles do not collide' do
      let!(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

      it 'does not add errors for separated circles' do
        circle1 = create(:circle, frame: frame, center_x: 50.0, center_y: 50.0, diameter: 20.0)
        circle2 = build(:circle, frame: frame, center_x: 150.0, center_y: 150.0, diameter: 20.0)
        validator.validate(circle2)
        expect(circle2.errors).to be_empty
      end
    end

    context 'when circles collide or touch' do
      let!(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

    it 'adds error for overlapping circles' do
      circle1 = create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 30.0)
      circle2 = build(:circle, frame: frame, center_x: 110.0, center_y: 100.0, diameter: 30.0)
      validator.validate(circle2)
      expect(circle2.errors[:base]).to include(/Círculo não pode colidir ou encostar em outro círculo/)
    end

    it 'adds error for touching circles' do
      circle1 = create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 30.0)
      circle2 = build(:circle, frame: frame, center_x: 130.0, center_y: 100.0, diameter: 30.0)
      validator.validate(circle2)
      expect(circle2.errors[:base]).to include(/Círculo não pode colidir ou encostar em outro círculo/)
    end

      it 'excludes itself from collision check when updating' do
        circle = create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 30.0)
        circle.center_x = 110.0
        validator.validate(circle)
        expect(circle.errors).to be_empty
      end
    end

    context 'when frame_id is not present' do
      it 'does not validate' do
        circle = build(:circle, frame: nil, center_x: 100.0, center_y: 100.0, diameter: 50.0)
        validator.validate(circle)
        expect(circle.errors).to be_empty
      end
    end
  end

  describe '#circles_collide_or_touch?' do
    let(:circle1) { build(:circle, center_x: 100.0, center_y: 100.0, diameter: 30.0) }
    let(:circle2) { build(:circle, center_x: 150.0, center_y: 100.0, diameter: 30.0) }

    it 'returns false for non-colliding circles' do
      result = validator.send(:circles_collide_or_touch?, circle1, circle2)
      expect(result).to be_falsey
    end

    it 'returns true for colliding circles' do
      circle2.center_x = 110.0
      result = validator.send(:circles_collide_or_touch?, circle1, circle2)
      expect(result).to be_truthy
    end

    it 'returns true for touching circles' do
      circle2.center_x = 130.0
      result = validator.send(:circles_collide_or_touch?, circle1, circle2)
      expect(result).to be_truthy
    end
  end
end
