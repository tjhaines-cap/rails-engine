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
      expect(Item.all).to eq([item])

      delete "/api/v1/items/#{item.id}"

      expect(response.status).to eq(204)
      expect(Item.all).to eq([])
    end

    it "can delete an item and invoice if the item is the only one on the invoice" do
      customer1 = create(:customer)
      merchant1 = create(:merchant)
      invoices = create_list(:invoice, 2, {customer_id: customer1.id, merchant_id: merchant1.id})
      item1 = create(:item, merchant_id: merchant1.id)
      item2 = create(:item, merchant_id: merchant1.id)
      invoice_item1 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices.first.id})
      invoice_item2 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices.last.id})
      invoice_item3 = create(:invoice_item, {item_id: item2.id, invoice_id: invoices.last.id})
      invoice_item4 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices.first.id})

      expect(Invoice.all.length).to eq(2)
      delete "/api/v1/items/#{item1.id}"

      expect(Invoice.all.length).to eq(1)
      expect(Invoice.all).to eq([invoices.last])
      expect(Item.all).to eq([item2])
    end

    it "can get the merchant data for an item" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item = create(:item, merchant_id: merchant1.id)

      get "/api/v1/items/#{item.id}/merchant"

      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      merchant = body[:data]

      expect(merchant.keys).to include(:id, :attributes)
      expect(merchant[:id]).to eq(merchant1.id.to_s)
      attributes = merchant[:attributes]
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to eq(merchant1.name)
    end

    it "can get all items that meet a partial case insensitive search for the name" do
      merchant1 = create(:merchant)
      create(:item, { name: "Wedding ring", merchant_id: merchant1.id })
      create(:item, { name: "Ring", merchant_id: merchant1.id })
      create(:item, { name: "Necklace", merchant_id: merchant1.id })
      
      get "/api/v1/items/find_all?name=ring"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items.length).to eq(2)
      expect(items[0][:attributes][:name]).to eq("Ring")
      expect(items[1][:attributes][:name]).to eq("Wedding ring")

    end

    it "can get all items based on min max price search criteria" do
      merchant1 = create(:merchant)
      create(:item, { unit_price: 105.99, merchant_id: merchant1.id })
      create(:item, { unit_price: 99.99, merchant_id: merchant1.id })
      create(:item, { unit_price: 85.99, merchant_id: merchant1.id })
      
      get "/api/v1/items/find_all?min_price=95"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items.length).to eq(2)
      expect(items[0][:attributes][:unit_price]).to eq(105.99)
      expect(items[1][:attributes][:unit_price]).to eq(99.99)

      get "/api/v1/items/find_all?max_price=100"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items.length).to eq(2)
      expect(items[0][:attributes][:unit_price]).to eq(99.99)
      expect(items[1][:attributes][:unit_price]).to eq(85.99)

      get "/api/v1/items/find_all?max_price=100&min_price=90"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items.length).to eq(1)
      expect(items[0][:attributes][:unit_price]).to eq(99.99)
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
    
    it "returns error if the item being deleted does not exist" do
      delete "/api/v1/items/532"
      expect(response.status).to eq(404)
    end
    
    it "returns error if invalid item id is given" do
      get "/api/v1/items/524/merchant"
      expect(response.status).to eq(404)
    end

    it "returns empty array if no items match search criteria" do
      merchant1 = create(:merchant)
      create(:item, { name: "Wedding ring", unit_price: 500.50, merchant_id: merchant1.id })
      create(:item, { name: "Ring", unit_price: 699.99, merchant_id: merchant1.id })
      
      get "/api/v1/items/find_all?name=doughnut"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items).to eq([])

      get "/api/v1/items/find_all?max_price=100&min_price=90"
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true)
      expect(body).to have_key(:data)
      items = body[:data]
      expect(items).to eq([])
    end
  end
end