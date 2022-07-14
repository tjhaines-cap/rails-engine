class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  def destroy_invoices
    self.invoices.each do |invoice|
      ids = invoice.items.ids
      ids.delete(self.id)
      if ids == []
        invoice.destroy
      end
    end
  end

  def self.find_by_name(name)
    order(:name).where("name ILIKE ?", "%#{name}%")
  end

  def self.find_by_price(min_max)
    if min_max.keys == [:min_price, :max_price]
      where("#{min_max[:min_price]} < unit_price").where("unit_price < #{min_max[:max_price]}")
    elsif min_max.keys == [:min_price]
      where("#{min_max[:min_price]} < unit_price")
    elsif min_max.keys == [:max_price]
      where("unit_price < #{min_max[:max_price]}")
    end
  end
end
