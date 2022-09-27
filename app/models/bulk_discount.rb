class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items

  validates :discount, presence: true, numericality: true
  validates :threshold, presence: true, numericality: { only_integer: true }

  def self.best_discount(invoice_item_quantity)
    where('threshold <= ?', invoice_item_quantity)
    .order(discount: :desc)
    .first
  end
end
