require 'rails_helper'

RSpec.describe Item, type: :model do
  it { should belong_to :merchant }
  it { should have_many :invoice_items }
  it { should have_many(:invoices).through(:invoice_items) }

  it "can destroy invoices where the current item is the only item on the invoice" do
    customer1 = create(:customer)
    merchant1 = create(:merchant)
    invoices = create_list(:invoice, 3, {customer_id: customer1.id, merchant_id: merchant1.id})
    item1 = create(:item, merchant_id: merchant1.id)
    item2 = create(:item, merchant_id: merchant1.id)
    invoice_item1 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices.first.id})
    invoice_item2 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices[1].id})
    invoice_item3 = create(:invoice_item, {item_id: item2.id, invoice_id: invoices.last.id})
    invoice_item4 = create(:invoice_item, {item_id: item1.id, invoice_id: invoices.last.id})

    expect(Invoice.all.length).to eq(3)
    item1.destroy_invoices
    expect(Invoice.all.length).to eq(1)
    expect(Invoice.all.first).to eq(invoices.last)
  end

  it "can find all items that is a partial case insensitive match for name given, sorted alphabetically" do
    merchant1 = create(:merchant)
    item1 = create(:item, { name: "Wedding ring", merchant_id: merchant1.id })
    item2 = create(:item, { name: "Ring", merchant_id: merchant1.id })
    item3 = create(:item, { name: "Necklace", merchant_id: merchant1.id })
    items = Item.find_by_name("ring")
    expect(items).to eq([item2, item1])
  end

  it "can find all items that meet a max and/or min price criteria" do 
    merchant1 = create(:merchant)
    item1 = create(:item, { unit_price: 105.99, merchant_id: merchant1.id })
    item2 = create(:item, { unit_price: 99.99, merchant_id: merchant1.id })
    item3 = create(:item, { unit_price: 85.99, merchant_id: merchant1.id })
    expect(Item.find_by_price({max_price: 100.00})).to eq([item2, item3])
    expect(Item.find_by_price({min_price: 89.99})).to eq([item1, item2])
    expect(Item.find_by_price({min_price: 89.99, max_price: 100.00})).to eq([item2])
  end
end