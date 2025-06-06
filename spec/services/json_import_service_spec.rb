require "rails_helper"

RSpec.describe JsonImportService do
  let(:file) { Rails.root.join("lib/deals.json") }

  it "creates 16 deals from fixture" do
    expect { described_class.call(file) }.to change(Deal, :count).by(16)
  end
end
