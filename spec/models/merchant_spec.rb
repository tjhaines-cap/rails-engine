require 'rails_helper'

RSpec.describe Merchant, type: :model do
  it { should have_many :items }

  it "can find first merchant that is a partial case insensitive match for name given, sorted alphabetically" do
    voodoo = create(:merchant, name: "Voodoo Doughnuts")
    doughnut = create(:merchant, name: "The best Doughnuts")
    merchant = Merchant.find_by_name("dough")
    expect(merchant).to eq(doughnut)
  end
end