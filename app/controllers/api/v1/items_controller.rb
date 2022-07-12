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
    item = Item.find(params[:id])
    item.update(item_params)
    render json: ItemSerializer.new(item)
  end

  private

    def item_params
      params.permit(:name, :description, :unit_price, :merchant_id)
    end

end