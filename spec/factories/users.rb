FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_weak_password do
      password { "123" }
      password_confirmation { "123" }
    end

    trait :with_invalid_email do
      email { "invalid-email" }
    end

    trait :without_name do
      name { "" }
    end
  end
end
