class Api::V1::ItemMerchantController < ApplicationController

  def index
    if Item.exists?()
    render json: MerchantSerializer.new(Item.find(params[:item_id]).merchant)
  end

end
