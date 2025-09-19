FactoryBot.define do
  factory :circle do
    association :frame

    # Create circle within frame bounds with random position
    transient do
      frame_center_x { frame&.center_x || 100.0 }
      frame_center_y { frame&.center_y || 100.0 }
      frame_width { frame&.width || 200.0 }
      frame_height { frame&.height || 150.0 }
    end

    # Random position within frame bounds (with margin for diameter)
    center_x { frame_center_x + rand(-frame_width/4..frame_width/4) }
    center_y { frame_center_y + rand(-frame_height/4..frame_height/4) }
    diameter { [ frame_width, frame_height ].min * 0.2 } # 20% of smallest frame dimension

    trait :small_circle do
      diameter { 10.0 }
    end

    trait :large_circle do
      diameter { [ frame_width, frame_height ].min * 0.6 } # 60% of smallest frame dimension
    end

    trait :tiny_circle do
      diameter { 0.1 }
    end

    trait :at_frame_center do
      center_x { frame_center_x }
      center_y { frame_center_y }
    end

    trait :near_frame_edge do
      center_x { frame_center_x + (frame_width * 0.3) }
      center_y { frame_center_y + (frame_height * 0.3) }
      diameter { 20.0 }
    end

    trait :non_overlapping do
      # Create circles that don't overlap by using different positions within frame bounds
      sequence(:center_x) { |n| frame_center_x + (n * 30.0 - 60.0) } # Start from left side
      sequence(:center_y) { |n| frame_center_y + (n * 25.0 - 50.0) } # Start from bottom
      diameter { 15.0 } # Smaller diameter to ensure they fit
    end
  end
end
