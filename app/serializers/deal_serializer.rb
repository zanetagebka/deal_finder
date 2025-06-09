class DealSerializer
  def initialize(deal)
    @deal = deal
  end

  def as_json(*)
    {
      id:       @deal.id,
      title:    @deal.title,
      discount: @deal.discount_percentage,
      price:    @deal.discount_price.to_f,
      ends_at:  @deal.expiry_date.to_s,
      featured: @deal.featured_deal,
      image:    @deal.image_url,
      location: location_json
    }
  end

  private

  def location_json(location = @deal.location)
    return nil unless location

    {
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
      city: location.city,
      state: location.state,
      zip_code: location.zip_code
    }
  end
end
