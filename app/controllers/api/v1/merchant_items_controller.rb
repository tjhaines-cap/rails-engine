class Api::V1::MerchantItemsController < ApplicationController

  def index
    if Merchant.exists?(params[:merchant_id])
      render json: ItemSerializer.new(Merchant.find(params[:merchant_id]).items)
    else
      render json: { message: "your query could not be completed", error: ["merchant does not exist"]}, status: :not_found
    end
  end

end