require "rails_helper"

RSpec.describe JsonImportService do
  subject(:service) { JsonImportService.call(Rails.root.join("lib", "deals.json")) }

  before(:all) do
    Deal.delete_all
  end

  it "creates 16 deals from fixture" do
    expect { subject }.to change(Deal, :count).by(16)
  end
end
