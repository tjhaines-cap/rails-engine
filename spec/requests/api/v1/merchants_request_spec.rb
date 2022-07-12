require 'rails_helper'

RSpec.describe "Merchants API" do

  it "gets all merchants" do
    create_list(:merchant, 5)

    get '/api/v1/merchants'

    expect(response).to be_successful

    body = JSON.parse(response.body, symbolize_names: true)

    expect(body).to have_key(:data)
    merchants = body[:data]
    expect(merchants.count).to eq(5)
    merchants.each do |merchant|
      expect(merchant.keys).to include(:id, :attributes)
      attributes = merchant[:attributes]
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
    end
  end

  it "gets one merchant" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful

    body = JSON.parse(response.body, symbolize_names: true)

    expect(body).to have_key(:data)
    merchant = body[:data]
    expect(merchant.keys).to include(:id, :attributes)
    attributes = merchant[:attributes]
    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)
  end

  it "gets merchant items" do
    id = create(:merchant).id
    create_list(:item, 5, merchant_id: id)

    get "/api/v1/merchants/#{id}/items"

    expect(response.status).to eq(200)
    expect(body).to have_key(:data)
    items = body[:data]
    expect(items.keys).to include(:id, :attributes)
    items.each do |item|
      expect(item.keys).to include(:id, :attributes)#, :relationships)
      attributes = item[:attributes]
      expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:name]).to be_a(String)
      expect(attributes[:unit_price]).to be_a(Float)
      expect(attributes[:merchant_id]).to be_a(Integer)
    end
  end
end