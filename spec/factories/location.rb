FactoryBot.define do
  factory :location do
    sequence(:address) { |n| "#{n} Test Street" }
    city { "San Francisco" }
    state { "CA" }
    zip_code { "94103" }
    latitude { 37.7749 }
    longitude { -122.4194 }
  end
end
