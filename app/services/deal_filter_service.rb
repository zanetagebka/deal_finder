class DealFilterService
  def self.call(params = {})
    new(params.symbolize_keys).call
  end

  def initialize(params)
    @p = params
  end

  def call
    query = Deal.all
    query = filter_by_category(query) if @p[:category].present?
    query = filter_by_subcategory(query) if @p[:subcategory].present?
    query = filter_by_price_range(query) if @p[:min].present? || @p[:max].present?
    query = filter_by_tag(query) if @p[:tag].present?
    query = filter_by_radius(query) if @p[:lat].present? && @p[:lon].present? && @p[:radius].present?
    query = filter_by_featured(query) if @p[:featured].present?
    query = filter_by_available(query) if @p[:available].present?
    filter_not_expired(query)
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

    tag_value = @p[:tag].downcase
    q.where("LOWER(tags::text) LIKE ?", "%#{tag_value}%")
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
    lat, lon, r = @p.values_at(:lat, :lon, :radius)
    return q unless lat && lon && r

    q.near([ lat, lon ], r, order: false)
  end
end
