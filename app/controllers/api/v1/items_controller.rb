class Api::V1::ItemsController < ApplicationController

  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    if Item.exists?(params[:id])
      render json: ItemSerializer.new(Item.find(params[:id]))
    else
      render status: :not_found
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      # item_serialized = ItemSerializer.new(item)
      render json: ItemSerializer.new(item), status: :created
    else
      render json: item.errors, status: :not_found
    end
  end

  def update
    if Item.exists?(params[:id])
      if (params[:merchant_id] && Merchant.exists?(params[:merchant_id])) || !params[:merchant_id]
          item = Item.find(params[:id])
          item.update(item_params)
          render json: ItemSerializer.new(item)
      else
        render status: :not_found
      end
    else
      render status: :not_found
    end
  end

  def destroy
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      item.destroy
    else
      render status: :not_found
    end
  end

  private

    def item_params
      params.permit(:name, :description, :unit_price, :merchant_id)
    end

end