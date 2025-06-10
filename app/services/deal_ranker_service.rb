class DealRankerService
  DEFAULT_WEIGHTS = {
    discount: 0.3,
    popularity: 0.2,
    distance: 0.2,
    expiration: 0.15,
    featured: 0.1,
    merchant_rating: 0.05
  }.freeze

  def initialize(deal_scope, weights = {})
    @deals = if deal_scope.respond_to?(:select) && deal_scope.respond_to?(:includes)
               deal_scope.select(
                 :id, :discount_percentage, :quantity_sold, :featured_deal,
                 :expiry_date, :merchant_id
               ).includes(merchant: :location)
    else
               deal_scope
    end
    @weights = normalize_weights(DEFAULT_WEIGHTS.merge(weights))
  end

  def ranked(lat: nil, lon: nil)
    deals_array = @deals.to_a

    if lat && lon
      rank_with_location(deals_array, lat, lon)
    else
      rank_without_location(deals_array)
    end
  end

  private

  def rank_with_location(deals, lat, lon)
    deals_with_location, deals_without_location = deals.partition do |deal|
      deal.merchant&.location&.latitude.present? &&
        deal.merchant&.location&.longitude.present?
    end

    sorted_with_location = deals_with_location.sort_by do |deal|
      [
        -deal.discount_percentage,
        deal.featured_deal ? 0 : 1,
        -deal.quantity_sold,
        deal.expiry_date
      ]
    end

    sorted_without_location = rank_without_location(deals_without_location)
    sorted_with_location + sorted_without_location
  end

  def rank_without_location(deals)
    deals.sort_by do |deal|
      [
        -deal.discount_percentage,
        deal.featured_deal ? 0 : 1,
        -deal.quantity_sold,
        deal.expiry_date
      ]
    end
  end

  def calculate_score_with_distance(deal, distance_score)
    discount_score = deal.discount_percentage / 100.0
    popularity_score_val = popularity_score(deal.quantity_sold)
    expiration_score_val = expiration_score(deal.expiry_date)
    featured_score = deal.featured_deal ? 1.0 : 0.0
    merchant_rating_score = deal.merchant&.rating || 0.0

    (@weights[:discount] * discount_score) +
      (@weights[:popularity] * popularity_score_val) +
      (@weights[:distance] * distance_score) +
      (@weights[:expiration] * expiration_score_val) +
      (@weights[:featured] * featured_score) +
      (@weights[:merchant_rating] * merchant_rating_score / 5.0)
  end

  def calculate_score(deal)
    discount_score = deal.discount_percentage / 100.0
    popularity_score_val = popularity_score(deal.quantity_sold)
    expiration_score_val = expiration_score(deal.expiry_date)
    featured_score = deal.featured_deal ? 1.0 : 0.0
    merchant_rating_score = deal.merchant&.rating || 0.0

    (@weights[:discount] * discount_score) +
      (@weights[:popularity] * popularity_score_val) +
      (@weights[:expiration] * expiration_score_val) +
      (@weights[:featured] * featured_score) +
      (@weights[:merchant_rating] * merchant_rating_score / 5.0)
  end

  def calculate_distance_score(distance_km)
    max_distance = 50.0
    return 1.0 if distance_km <= 0

    [ (max_distance - distance_km) / max_distance, 0.0 ].max
  end

  def popularity_score(quantity_sold)
    deals_array = @deals.respond_to?(:to_a) ? @deals.to_a : @deals
    max_quantity = deals_array.map(&:quantity_sold).max || 1

    return 0.0 if max_quantity == 0

    quantity_sold.to_f / max_quantity
  end

  def expiration_score(expiry_date)
    days_until_expiry = (expiry_date - Date.current).to_i
    return 0.0 if days_until_expiry <= 0

    [ 1.0 - (days_until_expiry.to_f / 30.0), 0.0 ].max
  end

  def has_location?(deal)
    return false unless deal.merchant
    return false unless deal.merchant.location

    location = deal.merchant.location
    location.latitude.present? && location.longitude.present?
  end

  def normalize_weights(weights)
    total = weights.values.sum.to_f
    weights.transform_values { |w| (w / total).round(2) }
  end
end
