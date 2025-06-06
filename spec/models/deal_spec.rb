require "rails_helper"

RSpec.describe Deal, type: :model do
  it "computes discount_pct from decimals" do
    deal = described_class.new(original_price: 100, discount_price: 40)
    expect(deal.discount_pct).to eq 0.6
  end
end
