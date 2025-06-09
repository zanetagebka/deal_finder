class DealRankerService
  DEFAULT_WEIGHTS = { discount: 0.6, popularity: 0.3, distance: 0.1 }.freeze

  def initialize(deals, weights = {})
    @deals   = deals
    @weights = DEFAULT_WEIGHTS.merge(weights)
  end

  def ranked(lat: nil, lon: nil)
    @deals.sort_by { |d| -score(d, lat:, lon:) }
  end

  private

  def score(deal, lat:, lon:)
    @weights[:discount] * (deal.discount_percentage.to_f / 100) +
      @weights[:popularity] * normalise(deal.quantity_sold.to_i, 0, 1000) +
      @weights[:distance] * distance_component(deal, lat, lon)
  end

  def normalise(v, min, max) = (v - min).to_f / (max - min)

  def distance_component(deal, lat, lon)
    return 1.0 unless lat && lon && deal.latitude && deal.longitude
    km = Geocoder::Calculations.distance_between([ lat, lon ], [ deal.latitude, deal.longitude ])
    1.0 / (1.0 + km)  # 0 km → 1 , 9 km → 0.1
  end
end
