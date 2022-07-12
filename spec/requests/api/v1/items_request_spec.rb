require 'rails_helper'

RSpec.describe "Items API" do

  it "gets all items" do
    merchant1 = create(:merchant)
    create_list(:item, 5, merchant_id: merchant1.id)

    get "/api/v1/items"
    
    expect(response).to be_successful

    body = JSON.parse(response.body, symbolize_names: true)
    expect(body).to have_key(:data)
    items = body[:data]
    expect(items.length).to eq(5)
    
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

  it "gets one item" do
    merchant1 = create(:merchant)
    id = create(:item, merchant_id: merchant1.id).id
    item2 = create(:item, merchant_id: merchant1.id)

    get "/api/v1/items/#{id}"

    expect(response.status).to eq(200)

    body = JSON.parse(response.body, symbolize_names: true)
    expect(body).to have_key(:data)
    item = body[:data]
    expect(item.keys).to include(:id, :attributes)
    expect(item[:id]).to eq("#{id}")
    expect(item[:id]).to_not eq("#{item2.id}")

    attributes = item[:attributes]
    expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
    expect(attributes[:name]).to be_a(String)
    expect(attributes[:name]).to be_a(String)
    expect(attributes[:unit_price]).to be_a(Float)
    expect(attributes[:merchant_id]).to be_a(Integer)
  end

  it "creates an item" do
    merchant1 = create(:merchant)
    post "/api/v1/items", params: {name: "Movie", description: "A DVD", unit_price: 15.00, merchant_id: merchant1.id}
    expect(response.status).to eq(201)
    body = JSON.parse(response.body, symbolize_names: true)
    
    expect(body).to have_key(:data)

    item = body[:data]
    attributes = item[:attributes]
    expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
    expect(attributes[:name]).to be_a(String)
    expect(attributes[:name]).to be_a(String)
    expect(attributes[:unit_price]).to be_a(Float)
    expect(attributes[:merchant_id]).to be_a(Integer)
  end

  it "returns error if any or all attributes are missing from post request" do
    merchant1 = create(:merchant)
    post "/api/v1/items", params: {name: "Movie", description: "A DVD", unit_price: 15.00}
    expect(response.status).to eq(422)
    post "/api/v1/items"
    expect(response.status).to eq(422)
  end
end