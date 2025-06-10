# frozen_string_literal: true

require 'active_model'

class DealsFilterParams
  include ActiveModel::Model

  attr_accessor :category, :subcategory, :min, :max, :lat, :lon, :radius, :tag, :featured, :available, :page

  validates :min, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :max, numericality: { allow_nil: true, greater_than_or_equal_to: 0 }, allow_blank: true
  validates :lat, numericality: { allow_nil: true, greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }, allow_blank: true
  validates :lon, numericality: { allow_nil: true, greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }, allow_blank: true
  validates :radius, numericality: { allow_nil: true, greater_than: 0 }, allow_blank: true
  validates :page, numericality: { only_integer: true, allow_nil: true, greater_than: 0 }, allow_blank: true
  validates :featured, inclusion: { in: [true, false, 'true', 'false', nil, '', 0, 1] }, allow_blank: true
  validates :available, inclusion: { in: [true, false, 'true', 'false', nil, '', 0, 1] }, allow_blank: true

  def initialize(params = {})
    super(params)
    coerce_types
  end

  def sanitized_params
    {
      category: category.presence,
      subcategory: subcategory.presence,
      min: min,
      max: max,
      lat: lat,
      lon: lon,
      radius: radius,
      tag: tag,
      featured: featured,
      available: available,
      page: page
    }.compact
  end

  private

  def coerce_types
    self.min = min.presence && min.to_f
    self.max = max.presence && max.to_f
    self.lat = lat.presence && lat.to_f
    self.lon = lon.presence && lon.to_f
    self.radius = radius.presence && radius.to_f
    self.page = page.presence && page.to_i
    self.featured = to_boolean(featured)
    self.available = to_boolean(available)
  end

  def to_boolean(val)
    return nil if val.nil? || (val.respond_to?(:empty?) && val.empty?)
    return true if val == true || val.to_s.downcase == 'true' || val.to_s == '1'
    return false if val == false || val.to_s.downcase == 'false' || val.to_s == '0'
    
    nil
  end
end 