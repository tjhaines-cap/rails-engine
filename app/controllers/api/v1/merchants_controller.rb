class Api::V1::MerchantsController < ApplicationController

    def index
      render json: MerchantSerializer.new(Merchant.all)
    end

    def show
      if Merchant.exists?(params[:id])
        render json: MerchantSerializer.new(Merchant.find(params[:id]))
      else
        render status: :not_found
      end
    end

    def find
      binding.pry
      merchant = Merchant.find_by_name(params[:name])
      if merchant 
        render json: MerchantSerializer.new(Merchant.find_by_name(params[:name]))
      else
        render json: MerchantSerializer.new(Merchant.new(id: nil, name: nil))
      end
    end

end