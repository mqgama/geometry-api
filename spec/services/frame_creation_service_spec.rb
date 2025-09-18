require 'rails_helper'

RSpec.describe FrameCreationService do
  let(:frame_params) do
    {
      center_x: 100.0,
      center_y: 100.0,
      width: 200.0,
      height: 150.0
    }
  end

  describe '#call' do
    context 'with valid frame parameters' do
      it 'creates a frame successfully' do
        service = FrameCreationService.new(frame_params)

        expect {
          frame = service.call
          expect(frame).to be_persisted
          expect(frame.center_x).to eq(100.0)
          expect(frame.center_y).to eq(100.0)
          expect(frame.width).to eq(200.0)
          expect(frame.height).to eq(150.0)
        }.to change(Frame, :count).by(1)
      end
    end

    context 'with circles parameters' do
      let(:circles_params) do
        [
          { center_x: 100.0, center_y: 100.0, diameter: 50.0 },
          { center_x: 150.0, center_y: 80.0, diameter: 30.0 }
        ]
      end

      it 'creates frame with circles' do
        service = FrameCreationService.new(frame_params, circles_params)

        expect {
          frame = service.call
          expect(frame.circles.count).to eq(2)
          expect(frame.circles.first.center_x).to eq(100.0)
          expect(frame.circles.last.center_x).to eq(150.0)
        }.to change(Frame, :count).by(1)
         .and change(Circle, :count).by(2)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          center_x: nil,
          center_y: 100.0,
          width: -10.0,
          height: 150.0
        }
      end

      it 'raises validation error' do
        service = FrameCreationService.new(invalid_params)

        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with frame collision' do
      before do
        create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0)
      end

      let(:colliding_params) do
        {
          center_x: 150.0,
          center_y: 100.0,
          width: 200.0,
          height: 150.0
        }
      end

      it 'raises validation error' do
        service = FrameCreationService.new(colliding_params)

        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'with circle collision' do
      let(:circles_params) do
        [
          { center_x: 100.0, center_y: 100.0, diameter: 50.0 },
          { center_x: 110.0, center_y: 100.0, diameter: 50.0 }
        ]
      end

      it 'raises validation error' do
        service = FrameCreationService.new(frame_params, circles_params)

        expect {
          service.call
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
