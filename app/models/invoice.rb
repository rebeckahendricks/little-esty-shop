class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions

  validates :customer_id, presence: true
  validates :status, presence: true
  enum status: [ :in_progress, :completed, :cancelled]

  def self.not_shipped_invoices
    joins(:invoice_items, :customer)
    .where('invoice_items.status != 2')
    .order(:created_at)
  end

  def total_revenue
    invoice_items
    .joins(:item)
    .sum('invoice_items.quantity * items.unit_price')
  end

  def total_discounted_revenue
    invoice_items
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end
end
