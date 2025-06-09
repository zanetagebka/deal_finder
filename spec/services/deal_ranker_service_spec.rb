require 'rails_helper'

RSpec.describe DealRankerService, type: :service do
  before(:all) do
    Deal.delete_all
    Merchant.delete_all
    Location.delete_all
  end

  let(:location) { create(:location, latitude: 34.0522, longitude: -118.2437) }
  let(:merchant) { create(:merchant, location:) }

  let!(:d_big_discount) do
    create(:deal,
           merchant:,
           title: "Big Discount Deal",
           discount_percentage: 70,
           original_price: 100,
           discount_price: 30,
           quantity_sold: 100
    )
  end

  let!(:d_high_popularity) do
    create(:deal,
           merchant:,
           title: "High Popularity Deal",
           discount_percentage: 20,
           original_price: 100,
           discount_price: 80,
           quantity_sold: 500
    )
  end

  let(:deal_scope) { Deal.where(id: [ d_big_discount.id, d_high_popularity.id ]) }

  it "prefers higher weighted score (discount 0.6 weight, popularity 0.4)" do
    service = DealRankerService.new(deal_scope, discount: 0.6, popularity: 0.4, distance: 0.0)
    ranked_deals = service.ranked

    expect(ranked_deals.first).to eq(d_big_discount)
    expect(ranked_deals.last).to eq(d_high_popularity)
  end
end
