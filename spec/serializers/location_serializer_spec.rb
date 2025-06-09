RSpec.describe LocationSerializer do
  let(:location) do
    instance_double(
      Location,
      id: 1,
      latitude: 37.7749,
      longitude: -122.4194,
      address: "123 Main St",
      city: "San Francisco",
      state: "CA",
      zip_code: "94103"
    )
  end

  it "returns a compact JSON hash" do
    expect(described_class.new(location).as_json).to eq(
      id: 1,
      latitude: 37.7749,
      longitude: -122.4194,
      address: "123 Main St",
      city: "San Francisco",
      state: "CA",
      zip_code: "94103"
    )
  end
end
