require "rails_helper"

RSpec.describe DealSerializer do
  let(:location) do
    instance_double(
      Location,
      id: 1,
      latitude: 37.7749,
      longitude: -122.4194,
      address: "123 Main St",
      city: "San Francisco",
      state: "CA",
      zip_code: "94103"
    )
  end

  let(:deal) do
    instance_double(
      Deal,
      id: 99,
      title: "Half-Price Sushi",
      discount_percentage: 50,
      discount_price: 44.99,
      expiry_date: Date.new(2025, 7, 15),
      image_url: "http://ex.com/sushi.jpg",
      featured_deal: true,
      location: location
    )
  end

  it "returns a compact JSON hash" do
    expect(described_class.new(deal).as_json).to eq(
                                                   id: 99,
                                                   title: "Half-Price Sushi",
                                                   discount: 50,
                                                   price: 44.99,
                                                   ends_at: "2025-07-15",
                                                   featured: true,
                                                   image: "http://ex.com/sushi.jpg",
                                                   location: {
                                                     id: 1,
                                                      latitude: 37.7749,
                                                      longitude: -122.4194,
                                                      address: "123 Main St",
                                                      city: "San Francisco",
                                                      state: "CA",
                                                      zip_code: "94103"
                                                    }
                                                 )
  end
end
