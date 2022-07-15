require 'rails_helper'

RSpec.describe "Merchants API" do

  describe "happy path" do
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
      id2 = create(:merchant).id
      create_list(:item, 5, merchant_id: id)
      item6 = create(:item, merchant_id: id2)

      get "/api/v1/merchants/#{id}/items"

      expect(response.status).to eq(200)
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
        expect(attributes[:merchant_id]).to eq(id)
        expect(attributes[:merchant_id]).to_not eq(id2)
      end
    end

    it "can find a single merchant which matches a search term" do
      create(:merchant, name: "Turing")
      create(:merchant, name: "Ring World")

      get "/api/v1/merchants/find?name=ring"
      
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      merchant = body[:data]
      attributes = merchant[:attributes]
      expect(attributes[:name]).to eq("Ring World")

    end
  end

  describe "sad path" do

    it "returns error if merchant requested does not exist" do
      get "/api/v1/merchants/535"
      expect(response.status).to eq(404)
    end

    it "returns error if items requested for merchant that does not exist" do
      get "/api/v1/merchants/535/items"
      expect(response.status).to eq(404)
    end

    it "returns object with nil values if no merchant name matches the provided search" do
      merchant = create(:merchant, name: "Turing")
      create(:merchant, name: "Ring World")

      get "/api/v1/merchants/find?name=hello"
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      merchant_body = body[:data]
      expect(merchant_body[:id]).to eq(nil)
      expect(merchant_body[:attributes][:name]).to eq(nil)
    end

    it "returns error when string instead of number is used for merchant id" do
      get "/api/v1/merchants/string-instead-of-integer/items"
      expect(response.status).to eq(404)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:error)
    end

    it "returns error if no params given for find" do
      merchant = create(:merchant, name: "Turing")
      create(:merchant, name: "Ring World")

      get "/api/v1/merchants/find"

      expect(response.status).to eq(400)
    end
  end
end