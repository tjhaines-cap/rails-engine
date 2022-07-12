class Api::V1::ItemsController < ApplicationController

  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    # binding.pry
    item = Item.new(item_params)
    if item.save
      item_serialized = ItemSerializer.new(item)
      render json: item_serialized, status: :created
    end
    # render json: ItemSerializer.new(item)
  end

  private

    def item_params
      params.permit(:name, :description, :unit_price, :merchant_id)
    end

end