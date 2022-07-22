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
      merchant = Merchant.find_by_name(params[:name])
      if !params[:name] || params[:name] == ""
        render status: :bad_request
      elsif merchant 
        render json: MerchantSerializer.new(Merchant.find_by_name(params[:name]))
      else
        render json: MerchantSerializer.new(Merchant.new(id: nil, name: nil))
      end
    end

    def most_items
      merchants = Merchant.top_merchants_by_item_sold(params[:quantity])
      render json: MerchantItemSoldSerializer.new(merchants)
    end

    def total_revenue
      merchants = Merchant.total_revenue(params[:start], params[:end])
      binding.pry
      render json: MerchantNameRevenueSerializer.new(merchants)
    end

end