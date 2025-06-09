require "rails_helper"

RSpec.describe JsonImportService do
  subject(:service) { JsonImportService.call(Rails.root.join("lib", "deals.json")) }

  before(:all) do
    Deal.delete_all
    Location.delete_all
    Merchant.delete_all
  end

  it "creates 16 deals from fixture" do
    expect { subject }.to change(Deal, :count).by(16)
  end

  it "creates locations for each deal" do
    expect { subject }.to change(Location, :count).by(15)
  end

  it "creates merchants for each deal" do
    expect { subject }.to change(Merchant, :count).by(15)
  end
end
