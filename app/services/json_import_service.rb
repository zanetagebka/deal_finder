class JsonImportService
  class << self
    def call(path)
      JSON.parse(File.read(path)).each { |h| upsert_deal(h) }
    end

    private

    def upsert_deal(h)
      deal = Deal.find_or_initialize_by(id: h["id"])

      deal.assign_attributes(
        title: h["title"],
        description: h["description"],
        original_price: h["originalPrice"],
        discount_price: h["discountPrice"],
        discount_percentage: h["discountPercentage"],
        category: h["category"],
        subcategory: h["subcategory"],

        latitude: h.dig("location", "lat"),
        longitude: h.dig("location", "lng"),
        address: h.dig("location", "address"),
        city: h.dig("location", "city"),
        state: h.dig("location", "state"),
        zip_code: h.dig("location", "zipCode"),

        merchant_name: h["merchantName"],
        merchant_rating: h["merchantRating"],
        quantity_sold: h["quantitySold"],
        review_count: h["reviewCount"],
        average_rating: h["averageRating"],
        available_quantity: h["availableQuantity"],
        expiry_date: h["expiryDate"],
        featured_deal: h["featuredDeal"],
        image_url: h["imageUrl"],
        fine_print: h["finePrint"],
        meta: h.except("location", "tags")
      )

      deal.tag_list = Array(h["tags"]).join(", ")

      deal.save!
      deal
    end
  end
end
