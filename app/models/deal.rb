class Deal < ApplicationRecord

  reverse_geocoded_by :latitude, :longitude

  # returns a float 0.0-1.0 (e.g. 0.6 = 60 % discount)
  def discount_pct
    return 0 if original_price.to_d.zero?
    1 - (discount_price / original_price).to_d
  end
end
