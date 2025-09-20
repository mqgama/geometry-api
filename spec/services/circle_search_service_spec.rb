require 'rails_helper'

RSpec.describe CircleSearchService do
  let(:frame) { create(:frame, center_x: 100.0, center_y: 100.0, width: 200.0, height: 150.0) }

  before do
    create(:circle, frame: frame, center_x: 100.0, center_y: 100.0, diameter: 50.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 80.0, diameter: 30.0)
    create(:circle, frame: frame, center_x: 150.0, center_y: 120.0, diameter: 40.0)
  end

  describe '#call' do
    context 'without filters' do
      it 'returns all circles' do
        service = CircleSearchService.new({})
        circles = service.call

        expect(circles.length).to eq(3)
      end
    end

    context 'with frame_id filter' do
      let(:other_frame) { create(:frame, center_x: 300.0, center_y: 300.0, width: 200.0, height: 150.0) }
      before { create(:circle, frame: other_frame, center_x: 300.0, center_y: 300.0, diameter: 50.0) }

      it 'returns circles from specific frame' do
        service = CircleSearchService.new({ frame_id: frame.id })
        circles = service.call

        expect(circles.length).to eq(3)
        expect(circles.all? { |c| c.frame_id == frame.id }).to be_truthy
      end
    end

    context 'with radius filter' do
      it 'returns circles within radius' do
        service = CircleSearchService.new({
          center_x: 100.0,
          center_y: 100.0,
          radius: 70.0
        })
        circles = service.call

        expect(circles.length).to eq(2)
        expect(circles.map(&:center_x)).to contain_exactly(100.0, 150.0)
      end
    end

    context 'with small radius filter' do
      it 'returns circles within small radius' do
        service = CircleSearchService.new({
          center_x: 100.0,
          center_y: 100.0,
          radius: 30.0
        })
        circles = service.call

        expect(circles.length).to eq(1)
        expect(circles.first.center_x).to eq(100.0)
      end
    end

    context 'with no matching circles' do
      it 'returns empty array' do
        service = CircleSearchService.new({
          center_x: 500.0,
          center_y: 500.0,
          radius: 10.0
        })
        circles = service.call

        expect(circles).to be_empty
      end
    end

    context 'with partial filters' do
      it 'ignores incomplete radius filter' do
        service = CircleSearchService.new({
          center_x: 100.0,
          radius: 50.0
        })
        circles = service.call

        expect(circles.length).to eq(3)
      end
    end

    context 'with frame_id and radius filters' do
      let(:other_frame) { create(:frame, center_x: 300.0, center_y: 300.0, width: 200.0, height: 150.0) }
      before { create(:circle, frame: other_frame, center_x: 300.0, center_y: 300.0, diameter: 50.0) }

      it 'applies both filters' do
        service = CircleSearchService.new({
          frame_id: frame.id,
          center_x: 100.0,
          center_y: 100.0,
          radius: 70.0
        })
        circles = service.call

        expect(circles.length).to eq(2)
        expect(circles.all? { |c| c.frame_id == frame.id }).to be_truthy
      end
    end
  end

  describe '#filter_circles_within_radius' do
    let(:circles) { Circle.all }

    it 'filters circles correctly' do
      service = CircleSearchService.new({
        center_x: 100.0,
        center_y: 100.0,
        radius: 100.0
      })
      filtered_circles = service.send(:filter_circles_within_radius, circles)

      expect(filtered_circles.length).to eq(3)
    end

    it 'excludes circles that extend beyond radius' do
      service_with_radius = CircleSearchService.new({
        center_x: 100.0,
        center_y: 100.0,
        radius: 30.0
      })

      filtered_circles = service_with_radius.send(:filter_circles_within_radius, circles)

      expect(filtered_circles.length).to eq(1)
      expect(filtered_circles.first.center_x).to eq(100.0)
    end
  end
end
