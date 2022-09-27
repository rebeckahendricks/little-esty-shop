require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:discount) }
    it { should validate_presence_of(:threshold) }
    it { should validate_numericality_of(:discount) }
    it { should validate_numericality_of(:threshold) }
  end

  describe 'class methods' do
    before :each do
      @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")
      @customer1 = Customer.create!(id: 45, first_name:"John", last_name:"Doe")

      @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
      @discount2 = BulkDiscount.create!(merchant_id: 45, discount: 30, threshold: 10)
      @discount3 = BulkDiscount.create!(merchant_id: 45, discount: 50, threshold: 20)

      @item1 = Item.create!(id: 45, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant1.id)
      @item2 = Item.create!(id: 46, name:"Medium basket", description:"Blue and medium", unit_price: 1399, merchant_id: @merchant1.id)

      @invoice1 = Invoice.create!(id: 45, customer_id: @customer1.id, status: 1)

      @invoice_item1 = InvoiceItem.create!(id: 45, item_id: @item1.id, invoice_id: @invoice1.id, quantity:1, unit_price:1499 , status: 0)
      @invoice_item2 = InvoiceItem.create!(id: 63, item_id: @item1.id, invoice_id: @invoice1.id, quantity:6, unit_price:1499 , status: 0)
      @invoice_item3 = InvoiceItem.create!(id: 64, item_id: @item1.id, invoice_id: @invoice1.id, quantity:17, unit_price:1499 , status: 0)
      @invoice_item4 = InvoiceItem.create!(id: 65, item_id: @item2.id, invoice_id: @invoice1.id, quantity:25, unit_price:1399 , status: 0)
    end

    describe '.best_discount(invoice_item_id)' do
      it 'can find the best bulk discount that applies to a certain invoice_item' do
        expect(BulkDiscount.best_discount(@invoice_item1.id)).to eq(nil)
        expect(BulkDiscount.best_discount(@invoice_item2.id)).to eq(@discount1)
        expect(BulkDiscount.best_discount(@invoice_item3.id)).to eq(@discount2)
        expect(BulkDiscount.best_discount(@invoice_item4.id)).to eq(@discount3)
      end
    end
  end
end
