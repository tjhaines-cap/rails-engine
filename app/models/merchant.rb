class Merchant < ApplicationRecord
  validates_presence_of :name
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.find_by_name(name)
    order(:name).where("name ILIKE ?", "%#{name}%").first
  end

  def self.top_merchants_by_revenue(quantity)
    Merchant.joins(invoices: [:invoice_items, :transactions])
            .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
            .select(:name, :id, 'SUM(invoice_items.quantity * invoice_items.unit_price) as revenue')
            .group(:id)
            .order(revenue: :desc)
            .limit(quantity)
  end

  def self.top_merchants_by_item_sold(quantity)
    Merchant.joins(invoices: [:invoice_items, :transactions])
            .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
            .select(:name, :id, 'SUM(invoice_items.quantity) as num_items')
            .group(:id)
            .order(num_items: :desc)
            .limit(quantity)
  end

  def self.total_revenue(start_date, end_date)
    Merchant.joins(invoices: [:invoice_items, :transactions]).where(transactions: {result: 'success'}, invoices: {status: 'shipped'}).where("invoice_items.updated_at::date > '#{start_date}'::date").where("invoice_items.updated_at::date < '#{end_date}'::date").select('SUM(invoice_items.quantity * invoice_items.unit_price) as revenue')
    # a = Merchant.joins(invoices: [:invoice_items, :transactions]).where(transactions: {result: 'success'}, invoices: {status: 'shipped'}).where("invoice_items.updated_at::date > '2012-01-01'::date").where("invoice_items.updated_at::date < '2012-05-20'::date").select('SUM(invoice_items.quantity * invoice_items.unit_price) as revenue')
    # binding.pry
  end

end
