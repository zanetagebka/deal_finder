class Api::V1::DealsController < ApplicationController
  # GET /api/v1/deals
  #
  # @description Returns a list of deals, filtered and sorted based on provided parameters
  #
  # @apiParam [String] category Filter deals by category name (case-insensitive)
  # @example category=Food & Drink
  #
  # @apiParam [String] subcategory Filter deals by subcategory name (case-insensitive)
  # @example subcategory=Restaurants
  # @apiParam [Float] min Minimum price for deals
  # @example min=10.5
  #
  # @apiParam [Float] max Maximum price for deals
  # @example max=100
  #
  # @apiParam [String, Array<String>] tag Filter by tag or tags
  # @example tag=wellness
  # @example tag[]=wellness&tag[]=spa
  # @example tag=wellness,spa,massage
  #
  # @apiParam [Float] lat Latitude for location-based search and distance ranking
  # @example lat=37.7749
  #
  # @apiParam [Float] lon Longitude for location-based search and distance ranking
  # @example lon=-122.4194
  #
  # @apiParam [Integer] radius Search radius in kilometers when using lat/lon
  # @example radius=10
  #
  # @apiParam [Boolean] featured Filter for featured deals only (true) or non-featured deals only (false)
  # @example featured=true
  #
  # @apiParam [Boolean] available Filter for deals with available quantity
  # @example available=true
  #
  # @apiParam [Integer] page Page number for pagination results (10 per page)
  # @example page=2
  #
  # @return [Array<Hash>] Array of deal objects with the following structure:
  #   - id [Integer]: Unique identifier for the deal
  #   - title [String]: Title/name of the deal
  #   - discount [Integer]: Discount percentage (0-100)
  #   - price [Float]: Current discounted price
  #   - ends_at [String]: Expiration date in YYYY-MM-DD format
  #   - featured [Boolean]: Whether this is a featured deal
  #   - image [String, null]: URL to the deal image if available
  #   - location [Hash]: Location information with name, address, lat, lon
  #   - tags [Array<String>]: List of tags associated with the deal
  #
  # @response_example
  # [
  #   {
  #     "id": 42,
  #     "title": "Half-price dining experience",
  #     "discount": 50,
  #     "price": 39.99,
  #     "ends_at": "2025-12-31",
  #     "featured": true,
  #     "image": "https://example.com/images/dining.jpg",
  #     "location": {
  #       "name": "Fancy Restaurant",
  #       "address": "123 Main St, San Francisco, CA",
  #       "lat": 37.7749,
  #       "lon": -122.4194
  #     },
  #     "tags": ["restaurant", "dinner", "fine-dining"]
  #   }
  # ]
  def index
    filter_params = DealsFilterParams.new(allowed_filter_params)
    unless filter_params.valid?
      return render json: { errors: filter_params.errors.full_messages }, status: :bad_request
    end
    filtered_deals_scope = DealFilterService.call(filter_params.sanitized_params)
    ranked_deal_ids = DealRankerService.new(filtered_deals_scope).ranked(
      lat: filter_params.lat, lon: filter_params.lon
    ).map(&:id)

    render json: DealPresenterService.call(ranked_deal_ids, filter_params.sanitized_params)
  end

  private

  def allowed_filter_params
    params.permit(
      :category, :subcategory, :min, :max, :lat, :lon, :radius, :tag, :featured, :available, :page
    ).to_h
  end
end
