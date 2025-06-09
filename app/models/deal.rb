class Deal < ApplicationRecord
  belongs_to :location, optional: true
  belongs_to :merchant

  acts_as_taggable_on :tags

  # returns a float 0.0-1.0 (e.g. 0.6 = 60 % discount)
  def discount_pct
    return 0 if original_price.to_d.zero?
    1 - (discount_price / original_price).to_d
  end
end
