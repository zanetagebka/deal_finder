require "rails_helper"

RSpec.describe DealRankerService do
  let(:location) do
    instance_double(
      Location,
      latitude: 37.77,
      longitude: -122.42
    )
  end
  let(:d_big_discount) do
    instance_double(Deal,
                    discount_percentage: 70,
                    quantity_sold: 10,
                    location: location)
  end
  let(:d_popular) do
    instance_double(Deal,
                    discount_percentage: 30,
                    quantity_sold: 700,
                    location: location)
  end
  let(:all) { [ d_big_discount, d_popular ] }

  subject(:ranked) { described_class.new(all).ranked }

  it "prefers higher weighted score (discount 0.6 weight, popularity 0.4)" do
    expect(ranked.first).to eq d_big_discount
  end

  context "with user location" do
    subject(:ranked) { described_class.new(all).ranked(lat: 37.77, lon: -122.42) }

    it "still returns same order if both deals at same spot" do
      expect(ranked.first).to eq d_big_discount
    end
  end
end
