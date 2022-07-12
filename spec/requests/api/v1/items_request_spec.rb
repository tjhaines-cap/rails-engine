require 'rails_helper'

RSpec.describe "Items API" do

  it "gets all items" do
    merchant1 = create(:merchant)
    create_list(:item, 5, merchant_id: merchant1.id)#, {merchant: merchant1, merchant_id: merchant1.id})

    get "/api/v1/items"
    
    expect(response).to be_successful

    body = JSON.parse(response.body, symbolize_names: true)
    expect(body).to have_key(:data)
    items = body[:data]
    items.each do |item|
      expect(item.keys).to include(:id, :attributes)
      attributes = item[:attributes]
      expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:unit_price]).to be_a(Float)
      expect(attributes[:merchant_id]).to be_a(Integer)
    end
  end
end