require "rails_helper"

RSpec.describe Merchant, type: :model do
  it { is_expected.to have_many(:deals).dependent(:nullify) }

  it "normalises names to ensure uniqueness" do
    Merchant.create(name: "Elite Fitness Club")
    expect {
      Merchant.find_or_create_by_normalised("elite fitness club")
    }.not_to change(Merchant, :count)
  end
end
