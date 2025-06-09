class MerchantSerializer
  def initialize(merchant)
    @merchant = merchant
  end

  def as_json(*)
    return {} unless @merchant

    {
      id: @merchant.id,
      name: @merchant.name,
      rating: @merchant.rating
    }
  end
end
