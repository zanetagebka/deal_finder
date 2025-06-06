class JsonImportService
  class << self
    def call(path)
      JSON.parse(File.read(path)).each { |h| create_deal(h) }
    end

    private

    def create_deal(h)
      Deal.create!(
        id:                 h["id"],
        title:              h["title"],
        description:        h["description"],
        original_price:     h["originalPrice"],
        discount_price:     h["discountPrice"],
        discount_percentage:h["discountPercentage"],
        category:           h["category"],
        subcategory:        h["subcategory"],
        tags:               h["tags"],
        latitude:           h.dig("location", "lat"),
        longitude:          h.dig("location", "lng"),
        address:            h.dig("location", "address"),
        city:               h.dig("location", "city"),
        state:              h.dig("location", "state"),
        zip_code:           h.dig("location", "zipCode"),
        merchant_name:      h["merchantName"],
        merchant_rating:    h["merchantRating"],
        quantity_sold:      h["quantitySold"],
        review_count:       h["reviewCount"],
        average_rating:     h["averageRating"],
        available_quantity: h["availableQuantity"],
        expiry_date:        h["expiryDate"],
        featured_deal:      h["featuredDeal"],
        image_url:          h["imageUrl"],
        fine_print:          h["finePrint"],
        meta:               h.except("location")
      )
    end
  end
end
