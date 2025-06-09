require "rails_helper"

RSpec.describe Location, type: :model do
  let(:location) { described_class.new(latitude: 1, longitude: 2) }

  it { is_expected.to have_many(:deals) }
end
