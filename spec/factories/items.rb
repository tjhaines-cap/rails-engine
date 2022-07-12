FactoryBot.define do
  factory :item do
    name { Faker::Name.name }
    description { Faker::Lorem.paragraph }
    unit_price { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    # merchant_id { factory.create(app/user::merchant.id) }
    # association :merchant
  end
end
