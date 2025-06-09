class MerchantSerializer
  def initialize(merchant)
    @merchant = merchant
  end

  def as_json(*)
    return {} unless @merchant

    {
      id: @merchant.id,
      name: @merchant.name,
      rating: @merchant.rating,
      location: LocationSerializer.new(@merchant.location).as_json
    }
  end
end
