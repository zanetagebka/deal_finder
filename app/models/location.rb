class Location < ApplicationRecord
  has_many :deals

  reverse_geocoded_by :latitude, :longitude
end
