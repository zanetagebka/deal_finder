require "rails_helper"

RSpec.describe DealFilterService do
  include ActiveSupport::Testing::TimeHelpers

  before(:all) { JsonImportService.call(Rails.root.join("lib/deals.json")) }

  def ids(params = {})
    DealFilterService.call(params).pluck(:id).map(&:to_s)
  end

  it "filters by open-ended price (min only)" do
    expect(ids(min: 100)).to match_array %w[5 6 11 14 16]
  end

  it "filters by tag (case-insensitive)" do
    expect(ids(tag: "Wellness")).to eq %w[2]
  end

  it "excludes expired deals automatically" do
    travel_to Date.new(2025, 10, 1) do
      expect(ids).not_to include("2")
    end
  end

  it "filters by radius ≈ 7 km around SF centre" do
    expect(ids(lat: 37.7749, lon: -122.4194, radius: 7))
      .to include("1", "2", "3")
    expect(ids(lat: 37.7749, lon: -122.4194, radius: 7))
      .not_to include("5") # Napa
  end
end
