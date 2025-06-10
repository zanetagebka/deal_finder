require "rails_helper"

RSpec.describe "Deals API", type: :request do
  before(:all) do
    Deal.delete_all
    JsonImportService.call(Rails.root.join("lib/deals.json"))
  end

  after(:all) do
    Deal.delete_all
  end

  let(:first_deal_json) { JSON.parse(response.body).first }

  describe "GET /api/v1/deals" do
    it "returns JSON for category filter" do
      get api_v1_deals_path, params: { category: "Food & Drink" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq 4 # Current state of deals.json
    end

    it "returns all non-expired deals when no filters are applied" do
      get api_v1_deals_path

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to be > 0
    end

    it "handles pagination correctly" do
      get api_v1_deals_path, params: { page: 1 }
      expect(response).to have_http_status(:ok)
      json_page1 = JSON.parse(response.body)

      get api_v1_deals_path, params: { page: 2 }
      expect(response).to have_http_status(:ok)
      json_page2 = JSON.parse(response.body)
      expect(json_page1.first["id"]).not_to eq(json_page2.first["id"])

      expect(json_page1).to be_an(Array)
    end

    it "filters by featured status" do
      get api_v1_deals_path, params: { featured: true }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response.all? { |deal| deal["featured"] == true }).to be true

      get api_v1_deals_path, params: { featured: false }
      expect(response).to have_http_status(:ok)
      json_response_not_featured = JSON.parse(response.body)
      expect(json_response_not_featured.all? { |deal| deal["featured"] == false }).to be true
    end

    it "returns an empty array when no deals match filters" do
      get api_v1_deals_path, params: { category: "NonExistentCategory123" }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to eq []
    end

    it "returns deals with the correct JSON structure" do
      get api_v1_deals_path
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)

      expected_keys = %w[id title discount category subcategory merchant price ends_at featured image tags]
      expect(first_deal_json.keys.sort).to eq expected_keys.sort
      expect(first_deal_json["id"]).to be_a(Numeric)
      expect(first_deal_json["title"]).to be_a(String)
      expect(first_deal_json["discount"]).to be_a(Numeric)
      expect(first_deal_json["price"]).to be_a(Float)
      expect(first_deal_json["ends_at"]).to match(/\d{4}-\d{2}-\d{2}/)
      expect(first_deal_json["featured"]).to be_in([ true, false ])
      expect(first_deal_json["image"]).to be_a(String).or be_nil
      expect(first_deal_json["merchant"]).to be_a(Hash)
    end

    it "ranks deals by location when lat/lon are provided" do
      get api_v1_deals_path, params: { lat: 37.7749, lon: -122.4194 } # San Francisco

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq 10
    end

    it "returns 400 for negative min price" do
      get api_v1_deals_path, params: { min: -10 }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["errors"]).to include(/Min/)
    end

    it "returns 400 for out-of-range latitude" do
      get api_v1_deals_path, params: { lat: 200 }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["errors"]).to include(/Lat/)
    end

    it "returns 400 for non-integer page" do
      get api_v1_deals_path, params: { page: "abc" }
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["errors"]).to include(/Page/)
    end

    it "returns 200 for valid parameters" do
      get api_v1_deals_path, params: { min: 10, max: 100, lat: 37.7, lon: -122.4, page: 1 }
      expect(response).to have_http_status(:ok)
    end
  end
end
