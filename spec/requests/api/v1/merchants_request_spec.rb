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

    merchant = JSON.parse(response.body, symbolize_names: true)

    # binding.pry
  end
end