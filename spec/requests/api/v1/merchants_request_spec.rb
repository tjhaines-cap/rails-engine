require 'rails_helper'

RSpec.describe "Merchants API" do

  it "gets all merchants" do
    create_list(:merchant, 5)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants.count).to eq(5)

    merchants.each do |merchant|
      expect(merchant.keys).to include(:id, :name)
      expect(merchant[:id]).to be_a(Integer)
      expect(merchant[:name]).to be_a(String)
    end
  end
end