class DealPresenterService
  def self.call(ranked_deals_or_ids, params)
    new(ranked_deals_or_ids, params).call
  end

  def initialize(ranked_deals_or_ids, params)
    @ranked_deals_or_ids = ranked_deals_or_ids
    @params = params
  end

  def call
    deals = if @ranked_deals_or_ids.is_a?(ActiveRecord::Relation)
      @ranked_deals_or_ids
    else
      deal_ids = @ranked_deals_or_ids
      Deal.where(id: deal_ids)
          .order(Arel.sql("array_position(ARRAY[#{deal_ids.join(',')}], deals.id)"))
    end

    deals = deals.joins(:tags, :taggings, merchant: :location).includes(
      :tags, :taggings,
      merchant: { location: {} }
    )

    deals.page(@params[:page])
         .per(10)
         .map { |deal| DealSerializer.new(deal).as_json }
  end
end
