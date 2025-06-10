require 'rails_helper'

RSpec.describe DealRankerService do
  before(:all) do
    Deal.delete_all
    Merchant.delete_all
    Location.delete_all
  end

  subject { described_class.new(Deal.all) }

  let!(:merchant_high_rating) { create(:merchant, rating: 5.0) }
  let!(:merchant_low_rating) { create(:merchant, rating: 3.0) }
  let!(:merchant_with_location) do
    create(:merchant, rating: 4.5, location: create(:location, latitude: 37.7749, longitude: -122.4194))
  end

  let!(:deal_high_discount) do
    create(:deal,
           discount_percentage: 90,
           quantity_sold: 200,
           featured_deal: false,
           expiry_date: Date.current + 10.days,
           merchant: merchant_high_rating)
  end

  let!(:deal_low_discount) do
    create(:deal,
           discount_percentage: 20,
           quantity_sold: 500,
           featured_deal: false,
           expiry_date: Date.current + 15.days,
           merchant: merchant_low_rating)
  end

  let!(:deal_featured) do
    create(:deal,
           discount_percentage: 50,
           quantity_sold: 300,
           featured_deal: true,
           expiry_date: Date.current + 20.days,
           merchant: merchant_high_rating)
  end

  let!(:deal_expiring_soon) do
    create(:deal,
           discount_percentage: 30,
           quantity_sold: 100,
           featured_deal: false,
           expiry_date: Date.current + 3.days,
           merchant: merchant_high_rating)
  end

  let!(:deal_with_location) do
    create(:deal,
           discount_percentage: 40,
           quantity_sold: 100,
           featured_deal: false,
           expiry_date: Date.current + 10.days,
           merchant: merchant_with_location)
  end

  describe '#ranked' do
    context 'when no location is provided' do
      it 'ranks deals based on discount percentage primarily' do
        ranked_deals = subject.ranked

        expect(ranked_deals.first).to eq(deal_high_discount)
        expect(ranked_deals.first.discount_percentage).to eq(90)
      end

      it 'ranks deals by popularity when discounts are equal' do
        deal_1 = create(:deal,
                        discount_percentage: 60,
                        quantity_sold: 300,
                        featured_deal: false,
                        expiry_date: Date.current + 10.days,
                        merchant: merchant_high_rating)
        deal_2 = create(:deal,
                        discount_percentage: 60,
                        quantity_sold: 500,
                        featured_deal: false,
                        expiry_date: Date.current + 10.days,
                        merchant: merchant_low_rating)

        service = DealRankerService.new(Deal.where(id: [deal_1.id, deal_2.id]))
        ranked_deals = service.ranked

        expect(ranked_deals.first).to eq(deal_2)
        expect(ranked_deals.first.quantity_sold).to eq(500)
        expect(ranked_deals.second).to eq(deal_1)
        expect(ranked_deals.second.quantity_sold).to eq(300)
      end

      it 'favors featured deals over non-featured with equal discounts and popularity' do
        deal_regular = create(:deal,
                              discount_percentage: 45,
                              quantity_sold: 250,
                              featured_deal: false,
                              expiry_date: Date.current + 10.days,
                              merchant: merchant_high_rating)
        deal_featured_test = create(:deal,
                                    discount_percentage: 45,
                                    quantity_sold: 250,
                                    featured_deal: true,
                                    expiry_date: Date.current + 10.days,
                                    merchant: merchant_high_rating)

        service = DealRankerService.new(Deal.where(id: [deal_regular.id, deal_featured_test.id]))
        ranked_deals = service.ranked

        expect(ranked_deals.first).to eq(deal_featured_test)
        expect(ranked_deals.first.featured_deal).to be true
        expect(ranked_deals.second).to eq(deal_regular)
        expect(ranked_deals.second.featured_deal).to be false
      end

      it 'considers expiry date when other factors are equal' do
        deal_expiring_later = create(:deal,
                                     discount_percentage: 35,
                                     quantity_sold: 150,
                                     featured_deal: false,
                                     expiry_date: Date.current + 20.days,
                                     merchant: merchant_high_rating)
        deal_expiring_sooner = create(:deal,
                                      discount_percentage: 35,
                                      quantity_sold: 150,
                                      featured_deal: false,
                                      expiry_date: Date.current + 5.days,
                                      merchant: merchant_high_rating)

        service = DealRankerService.new(Deal.where(id: [deal_expiring_later.id, deal_expiring_sooner.id]))
        ranked_deals = service.ranked

        expect(ranked_deals.first).to eq(deal_expiring_sooner)
        expect(ranked_deals.second).to eq(deal_expiring_later)
      end
    end

    context 'when latitude and longitude are provided' do
      it 'handles deals without merchant locations gracefully' do
        lat = 37.7749
        lon = -122.4194

        deals_without_location = Deal.where.not(id: deal_with_location.id)
        service = DealRankerService.new(deals_without_location)
        ranked_deals = service.ranked(lat: lat, lon: lon)

        expect(ranked_deals).not_to include(deal_with_location)
        expect(ranked_deals).to include(deal_high_discount)
        expect(ranked_deals.first).to eq(deal_high_discount)
      end

      it 'ranks deals without location after deals with location' do
        ranked_deals = subject.ranked(lat: 37.7749, lon: -122.4194)

        deal_with_location_index = ranked_deals.index(deal_with_location)

        deals_without_location_ids = [
          deal_high_discount,
          deal_low_discount,
          deal_featured,
          deal_expiring_soon
        ].select do |deal|
          deal.merchant.location.nil? ||
            deal.merchant.location.latitude.nil? ||
            deal.merchant.location.longitude.nil?
        end

        deals_without_location_ids.each do |deal|
          deal_index = ranked_deals.index(deal)
          next if deal_index.nil?

          expect(deal_with_location_index).to be < deal_index
        end
      end
    end
  end

  describe '#popularity_score' do
    it 'normalizes quantity_sold correctly' do
      deal_1 = create(:deal, quantity_sold: 50)
      deal_2 = create(:deal, quantity_sold: 200)

      deal_scope = Deal.where(id: [deal_1.id, deal_2.id])
      service = DealRankerService.new(deal_scope)
      max_quantity = 200

      score_1 = service.send(:popularity_score, deal_1.quantity_sold)
      score_2 = service.send(:popularity_score, deal_2.quantity_sold)

      expect(score_1).to eq(50.0 / max_quantity)
      expect(score_2).to eq(200.0 / max_quantity)
      expect(score_2).to eq(1.0)
    end

    it 'handles edge case with zero max quantity' do
      deal = create(:deal, quantity_sold: 0)
      deal_scope = Deal.where(id: deal.id)
      service = DealRankerService.new(deal_scope)

      score = service.send(:popularity_score, 0)
      expect(score).to eq(0.0)

      score_with_input = service.send(:popularity_score, 10)
      expect(score_with_input).to eq(0.0)
    end
  end

  describe 'integration tests' do
    it 'produces consistent ranking results' do
      first_ranking = subject.ranked
      second_ranking = subject.ranked

      expect(first_ranking.map(&:id)).to eq(second_ranking.map(&:id))
    end

    it 'handles empty deal set gracefully' do
      empty_deals = Deal.none
      service = DealRankerService.new(empty_deals)

      ranked_deals = service.ranked
      expect(ranked_deals).to be_empty
    end
  end
end