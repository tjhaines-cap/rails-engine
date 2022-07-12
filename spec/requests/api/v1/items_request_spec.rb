require 'rails_helper'

RSpec.describe "Items API" do

  describe "happy path" do
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
        expect(attributes[:description]).to be_a(String)
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
      expect(attributes[:description]).to be_a(String)
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
      expect(attributes[:description]).to be_a(String)
      expect(attributes[:unit_price]).to be_a(Float)
      expect(attributes[:merchant_id]).to be_a(Integer)
    end

    it "can update an item" do
      merchant1 = create(:merchant)
      id = create(:item, merchant_id: merchant1.id).id

      patch "/api/v1/items/#{id}", params: {name: "Movie", description: "A DVD", unit_price: 15.99, merchant_id: merchant1.id}

      expect(response.status).to eq(200) 
      body = JSON.parse(response.body, symbolize_names: true)
      item = body[:data]
      attributes = item[:attributes]
      expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
      expect(attributes[:name]).to eq("Movie")
      expect(attributes[:description]).to eq("A DVD")
      expect(attributes[:unit_price]).to eq(15.99)
      expect(attributes[:merchant_id]).to eq(merchant1.id)
    end

    it "can update item with only partial data" do
      merchant1 = create(:merchant)
      item = create(:item, merchant_id: merchant1.id)

      patch "/api/v1/items/#{item.id}", params: {name: "Movie", description: "A DVD"}

      expect(response.status).to eq(200) 
      body = JSON.parse(response.body, symbolize_names: true)
      item_data = body[:data]
      attributes = item_data[:attributes]
    
      expect(attributes.keys).to include(:name, :description, :unit_price, :merchant_id)
      expect(attributes[:name]).to eq("Movie")
      expect(attributes[:description]).to eq("A DVD")
      expect(attributes[:unit_price]).to eq(item.unit_price)
      expect(attributes[:merchant_id]).to eq(item.merchant_id)
    end

    it "can delete an item" do
      merchant1 = create(:merchant)
      item = create(:item, merchant_id: merchant1.id)

      delete "/api/v1/items/#{item.id}"

      expect(response.status).to eq(204)
    end
  end

  describe "sad path" do
    
    it "returns error if item requested does not exist" do
      get "/api/v1/items/535"
      expect(response.status).to eq(404)
    end

    it "returns error if any or all attributes are missing from post request" do
      merchant1 = create(:merchant)
      post "/api/v1/items", params: {name: "Movie", description: "A DVD", unit_price: 15.00}
      expect(response.status).to eq(404)
      post "/api/v1/items"
      expect(response.status).to eq(404)
    end

    it "returns error if invlaid item id is given in patch request path" do
      patch "/api/v1/items/535"
      expect(response.status).to eq(404)
    end

    it "returns error if invlaid merchant id is given for patch request" do
      merchant1 = create(:merchant)
      id = create(:item, merchant_id: merchant1.id).id
      patch "/api/v1/items/#{id}", params: {name: "Movie", description: "A DVD", unit_price: 15.99, merchant_id: 235}
      expect(response.status).to eq(404)
    end
  end
end