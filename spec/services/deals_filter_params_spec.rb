require 'rails_helper'

RSpec.describe DealsFilterParams do
  describe 'validations' do
    it 'accepts valid parameters' do
      params = described_class.new(
        category: 'Food',
        subcategory: 'Restaurant',
        min: '10',
        max: '100',
        lat: '37.7',
        lon: '-122.4',
        radius: '5',
        tag: 'sushi',
        featured: 'true',
        available: 'false',
        page: '2'
      )
      expect(params).to be_valid
    end

    it 'rejects negative min' do
      params = described_class.new(min: -1)
      expect(params).not_to be_valid
      expect(params.errors[:min]).to be_present
    end

    it 'rejects negative max' do
      params = described_class.new(max: -5)
      expect(params).not_to be_valid
      expect(params.errors[:max]).to be_present
    end

    it 'rejects out-of-range latitude' do
      params = described_class.new(lat: 100)
      expect(params).not_to be_valid
      expect(params.errors[:lat]).to be_present
    end

    it 'rejects out-of-range longitude' do
      params = described_class.new(lon: -200)
      expect(params).not_to be_valid
      expect(params.errors[:lon]).to be_present
    end

    it 'rejects non-integer page' do
      params = described_class.new(page: 'abc')
      expect(params).not_to be_valid
      expect(params.errors[:page]).to be_present
    end

    it 'coerces booleans for featured and available' do
      params = described_class.new(featured: '1', available: 'false')
      expect(params.featured).to eq true
      expect(params.available).to eq false
    end

    it 'returns sanitized params' do
      params = described_class.new(category: 'Food', min: '10', featured: 'true', page: '1')
      expect(params.sanitized_params).to include(category: 'Food', min: 10.0, featured: true, page: 1)
    end
  end
end 