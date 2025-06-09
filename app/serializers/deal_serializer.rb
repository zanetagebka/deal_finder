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
      merchant: MerchantSerializer.new(@deal.merchant).as_json
    }
  end
end
