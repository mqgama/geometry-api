FactoryBot.define do
  factory :frame do
    center_x { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    center_y { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    width { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    height { Faker::Number.decimal(l_digits: 3, r_digits: 2) }

    trait :with_circles do
      after(:create) do |frame|
        create_list(:circle, 3, frame: frame)
      end
    end

    trait :large_frame do
      center_x { 1000.0 }
      center_y { 1000.0 }
      width { 2000.0 }
      height { 1500.0 }
    end

    trait :small_frame do
      center_x { 10.0 }
      center_y { 10.0 }
      width { 20.0 }
      height { 15.0 }
    end
  end
end
