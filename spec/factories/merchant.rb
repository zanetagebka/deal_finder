FactoryBot.define do
  factory :merchant do
    sequence(:name) { |n| "Merchant #{n}" }
    rating { 4.5 }
  end
end
