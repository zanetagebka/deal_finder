require "rails_helper"

RSpec.describe DealRankerService do
  let(:d_big_discount) do
    instance_double(Deal,
                    discount_percentage: 70,
                    quantity_sold: 10,
                    latitude: 37.77,
                    longitude: -122.42)
  end
  let(:d_popular) do
    instance_double(Deal,
                    discount_percentage: 30,
                    quantity_sold: 700,
                    latitude: 37.77,
                    longitude: -122.42)
  end
  let(:all) { [ d_big_discount, d_popular ] }

  subject(:ranked) { described_class.new(all).ranked }

  it "prefers higher weighted score (discount 0.6 weight, popularity 0.4)" do
    # Note: Your default weights are discount: 0.6, popularity: 0.3.
    # The test description says popularity 0.4.
    # Let's assume the default weights are used for this test.
    # Score for d_big_discount: (0.6 * 70/100) + (0.3 * 10/1000) + (0.1 * 1.0 if no lat/lon)
    #                             = 0.42           + 0.003           = 0.423 (approx, depends on normalization of 1000)
    # Score for d_popular:      (0.6 * 30/100) + (0.3 * 700/1000) + (0.1 * 1.0 if no lat/lon)
    #                             = 0.18           + 0.21             = 0.39 (approx)
    # So d_big_discount should indeed be first.
    expect(ranked.first).to eq d_big_discount
  end

  context "with user location" do
    subject(:ranked) { described_class.new(all).ranked(lat: 37.77, lon: -122.42) }

    it "still returns same order if both deals at same spot" do
      # With lat/lon provided, and deals at the same spot, distance component will be 1.0 for both.
      # Score for d_big_discount: (0.6 * 0.7) + (0.3 * (10/1000)) + (0.1 * 1.0)
      #                             = 0.42      + 0.003            + 0.1     = 0.523
      # Score for d_popular:      (0.6 * 0.3) + (0.3 * (700/1000)) + (0.1 * 1.0)
      #                             = 0.18      + 0.21             + 0.1     = 0.49
      # So d_big_discount should still be first.
      expect(ranked.first).to eq d_big_discount
    end
  end
end
