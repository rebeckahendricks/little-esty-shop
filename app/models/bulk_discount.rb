class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items

  validates :discount, presence: true, numericality: true
  validates :threshold, presence: true, numericality: true
end
