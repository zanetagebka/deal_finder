class Merchant < ApplicationRecord
  has_many :deals, dependent: :nullify
  belongs_to :location, optional: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.find_or_create_by_normalised(raw_name, rating = nil)
    where("LOWER(name) = ?", raw_name.strip.downcase)
      .first_or_create!(name: raw_name.strip, rating: rating)
  end
end
