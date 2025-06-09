class DealPresenterService
  def self.call(ranked_deal_ids, params)
    new(ranked_deal_ids, params).call
  end

  def initialize(ranked_deal_ids, params)
    @ranked_deal_ids = ranked_deal_ids
    @params = params
  end

  def call
    deals = Deal.includes(:location, :merchant, :taggings, :tags)
                .joins(:tags, :location, :merchant)
                .find(@ranked_deal_ids)

    deals_in_ranked_order = @ranked_deal_ids.map { |id| deals.find { |deal| deal.id == id } }.compact

    paged_deals = Kaminari.paginate_array(deals_in_ranked_order).page(@params[:page]).per(10)

    paged_deals.map do |deal|
      DealSerializer.new(deal).as_json
    end
  end
end
