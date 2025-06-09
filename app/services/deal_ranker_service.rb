class DealRankerService
  DEFAULT_WEIGHTS = { discount: 0.6, popularity: 0.3, distance: 0.1 }.freeze

  def initialize(deal_scope, weights = {})
    @deals = deal_scope.select(
      :id, :discount_percentage, :quantity_sold, :location_id, :merchant_id
    )
    @weights = DEFAULT_WEIGHTS.merge(weights)
  end

  def ranked(lat: nil, lon: nil)
    @deals.includes(:location, :merchant).to_a.sort_by { |d| -score(d, lat:, lon:) }
  end

  private

  def score(deal, lat:, lon:)
    @weights[:discount] * (deal.discount_percentage.to_f / 100) +
      @weights[:popularity] * normalise(deal.quantity_sold.to_i, 0, 1000) +
      @weights[:distance] * distance_component(deal, lat, lon)
  end

  def normalise(v, min, max) = (v - min).to_f / (max - min)

  def distance_component(deal, lat, lon)
    return 1.0 unless lat && lon

    # Get location through merchant
    deal_location = deal.merchant.location
    return 1.0 unless deal_location

    deal_lat = deal_location.latitude
    deal_lon = deal_location.longitude

    return 1.0 unless deal_lat && deal_lon

    km = Geocoder::Calculations.distance_between([lat, lon], [deal_lat, deal_lon])
    1.0 / (1.0 + km) # 0 km → 1 , 9 km → 0.1
  end
end
