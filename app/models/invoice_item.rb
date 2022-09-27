class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  belongs_to :bulk_discount, optional: true

  validates :item_id, presence: true
  validates :invoice_id, presence: true
  validates :quantity, presence: true
  validates :unit_price, presence: true
  validates :status, presence: true
  enum status: [:pending, :packaged, :shipped]

  def self.for_merchant(merchant_id)
    select("invoice_items.item_id, invoice_items.status, invoice_items.unit_price, invoice_items.quantity")
      .joins(item: [:invoice_items])
      .where("items.merchant_id = #{merchant_id}")
  end

  def discounted_price(percent_discount)
    item.unit_price * (100 - percent_discount.to_i) / 100
  end

  def apply_new_discount?(threshold, percent_discount)
    quantity >= threshold.to_i && discounted_price(percent_discount.to_i) < unit_price
  end

  def discounted?
    item.unit_price != unit_price
  end
end
