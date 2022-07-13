class Api::V1::ItemMerchantController < ApplicationController

  def index
    if Item.exists?(params[:item_id])
      render json: MerchantSerializer.new(Item.find(params[:item_id]).merchant)
    else
      render status: :not_found
    end
  end

end
