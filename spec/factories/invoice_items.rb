FactoryBot.define do
  factory :invoice_item do
    item_id { "MyString" }
    invoice_id { "MyString" }
    quantity { 1 }
    unit_price { 1.5 }
  end
end
