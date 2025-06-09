class Location < ApplicationRecord
  has_many :merchants
  has_many :deals, through: :merchants

  reverse_geocoded_by :latitude, :longitude
end
