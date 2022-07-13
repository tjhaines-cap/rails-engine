FactoryBot.define do
  factory :invoice do
    customer_id { "MyString" }
    merchant_id { "" }
    status { "MyString" }
  end
end
