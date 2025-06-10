class DealPresenterService
  def self.call(ranked_deals_or_ids, params)
    new(ranked_deals_or_ids, params).call
  end

  def initialize(ranked_deals_or_ids, params)
    @ranked_deals_or_ids = ranked_deals_or_ids
    @params = params
  end

  def call
    if @ranked_deals_or_ids.is_a?(ActiveRecord::Relation)
      deals = @ranked_deals_or_ids
    else
      deal_ids = @ranked_deals_or_ids

      deals = Deal.includes(:tags, merchant: :location)
                  .where(id: deal_ids)

      if deal_ids.any?
        deals = deals.order(Arel.sql("array_position(ARRAY[#{deal_ids.join(',')}], id)"))
      end
    end

    paged_deals = Kaminari.paginate_array(deals.to_a).page(@params[:page]).per(10)

    paged_deals.map do |deal|
      DealSerializer.new(deal).as_json
    end
  end
end
