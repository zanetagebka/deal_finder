class DealFilterService
  def self.call(params = {})
    new(params).call
  end

  def initialize(params)
    @p = params
  end

  def call
    query = Deal.includes(merchant: :location).joins(merchant: :location).all
    query = filter_by_category(query) if @p[:category].present?
    query = filter_by_subcategory(query) if @p[:subcategory].present?
    query = filter_by_price_range(query) if @p[:min].present? || @p[:max].present?
    query = filter_by_tag(query) if @p[:tag].present?
    query = filter_by_radius(query) if @p[:lat].present? && @p[:lon].present? && @p[:radius].present?
    query = filter_by_featured(query) if @p.key?(:featured)
    query = filter_by_available(query) if @p[:available].present?
    query = filter_not_expired(query)
    query.distinct
  end

  private

  def filter_by_category(q)
    return q unless @p[:category].present?

    q.where("LOWER(category) = ?", @p[:category].downcase)
  end

  def filter_by_subcategory(q)
    return q unless @p[:subcategory].present?

    q.where("LOWER(subcategory) = ?", @p[:subcategory].downcase)
  end

  def filter_by_price_range(q)
    min, max = @p.values_at(:min, :max).map(&:to_f)

    q = q.where("discount_price >= ?", min) if min.positive?
    q = q.where("discount_price <= ?", max) if max.positive?
    q
  end

  def filter_by_tag(q)
    return q unless @p[:tag].present?

    tags = normalize_tags_input(@p[:tag])

    q.includes(:tags).joins(:tags)
     .where("LOWER(tags.name) SIMILAR TO ?", "%(#{tags.join('|')})%")
     .distinct
  end

  def normalize_tags_input(tag_param)
    tags = Array(tag_param)

    if tags.size == 1 && tags.first.is_a?(String) && tags.first.include?(",")
      tags = tags.first.split(",").map(&:strip)
    end

    tags.map(&:downcase)
  end

  def filter_by_featured(q)
    return q unless @p.key?(:featured)

    flag = ActiveModel::Type::Boolean.new.cast(@p[:featured])
    q.where(featured_deal: flag)
  end

  def filter_by_available(q)
    return q unless @p[:available]

    q.where("available_quantity IS NOT NULL OR available_quantity > 0")
  end

  def filter_not_expired(q)
    q.where("expiry_date >= ?", Time.current.to_date)
  end

  def filter_by_radius(q)
    lat, lon, radius = @p.values_at(:lat, :lon, :radius)
    return q unless lat && lon && radius

    nearby_locations = Location.near([ lat, lon ], radius, units: :km, order: false)
    location_ids = nearby_locations.pluck(:id)

    q.joins(:merchant).where(merchants: { location_id: location_ids })
  end
end
