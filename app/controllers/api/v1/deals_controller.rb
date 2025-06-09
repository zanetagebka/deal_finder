class Api::V1::DealsController < ApplicationController
  def index
    filtered_deals = DealFilterService.call(params.permit!.to_h)
    ranked_deals = DealRankerService.new(filtered_deals).ranked(
      lat: params[:lat], lon: params[:lon]
    )

    paged_deals = Kaminari.paginate_array(ranked_deals).page(params[:page]).per(10)
    render json: paged_deals.map { |d| DealSerializer.new(d).as_json }
  end
end
