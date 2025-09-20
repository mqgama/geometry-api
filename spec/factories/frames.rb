FactoryBot.define do
  factory :frame do
    # Create frames with non-overlapping positions
    sequence(:center_x) { |n| n * 300.0 + 100.0 } # Space frames 300 units apart
    sequence(:center_y) { |n| n * 250.0 + 100.0 } # Space frames 250 units apart
    width { 200.0 }
    height { 150.0 }

    trait :with_circles do
      after(:create) do |frame|
        # Create circles that fit within the frame and don't overlap
        create_list(:circle, 3, :non_overlapping, frame: frame)
      end
    end

    trait :large_frame do
      center_x { 1000.0 }
      center_y { 1000.0 }
      width { 2000.0 }
      height { 1500.0 }
    end

    trait :small_frame do
      center_x { 50.0 }
      center_y { 50.0 }
      width { 100.0 }
      height { 80.0 }
    end

    trait :at_origin do
      center_x { 0.0 }
      center_y { 0.0 }
      width { 100.0 }
      height { 80.0 }
    end
  end
end
