FactoryBot.define do
  factory :deal do
    sequence(:title) { |n| "Deal #{n}" }
    description { "This is a test deal description" }
    original_price { 100.0 }
    discount_price { 70.0 }
    discount_percentage { 30 }
    category { "food" }
    subcategory { "restaurant" }
    quantity_sold { 50 }
    expiry_date { 1.month.from_now }
    featured_deal { false }

    association :merchant
  end
end
