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
end
