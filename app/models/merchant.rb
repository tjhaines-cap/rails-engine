class Merchant < ApplicationRecord
  has_many :items

  def self.find_by_name(name)
    order(:name).where("name ILIKE ?", "%#{name}%").first
  end
end
