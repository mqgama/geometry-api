FactoryBot.define do
  factory :circle do
    association :frame
    center_x { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    center_y { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    diameter { Faker::Number.decimal(l_digits: 2, r_digits: 2) }

    trait :small_circle do
      center_x { 50.0 }
      center_y { 50.0 }
      diameter { 10.0 }
    end

    trait :large_circle do
      center_x { 500.0 }
      center_y { 500.0 }
      diameter { 200.0 }
    end

    trait :tiny_circle do
      center_x { 10.0 }
      center_y { 10.0 }
      diameter { 0.1 }
    end
  end
end
