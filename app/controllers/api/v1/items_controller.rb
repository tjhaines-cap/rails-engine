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
      item_serialized = ItemSerializer.new(item)
      render json: item_serialized, status: :created
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  private

    def item_params
      params.permit(:name, :description, :unit_price, :merchant_id)
    end

end