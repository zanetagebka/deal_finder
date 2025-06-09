class LocationSerializer
  def initialize(location)
    @location = location
  end

  def as_json(*)
    return {} unless @location

    {
      id: @location.id,
      latitude: @location.latitude,
      longitude: @location.longitude,
      address: @location.address,
      city: @location.city,
      state: @location.state,
      zip_code: @location.zip_code
    }
  end
end
