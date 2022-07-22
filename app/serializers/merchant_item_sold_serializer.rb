class MerchantItemSoldSerializer
  include JSONAPI::Serializer
  attributes :name

  attributes :count do |merchant|
    merchant.num_items
  end
end