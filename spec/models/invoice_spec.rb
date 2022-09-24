require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to(:customer) }
    it { should have_many(:invoice_items) }
    it { should have_many(:transactions) }
    it { should have_many(:items).through (:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:customer_id) }
    it { should validate_presence_of(:status) }
  end

  describe '.not_shipped_invoices' do
    it "Should return invoice id's in creation order" do
      invoice_ids = [5, 5, 7, 3, 3, 3, 3, 3, 2, 2, 2, 4, 4, 1, 1, 1, 1, 1]

      expect(Invoice.not_shipped_invoices.ids).to eq invoice_ids
      expect(Invoice.not_shipped_invoices.ids.count).to eq 18
    end
  end

  describe 'Total Revenue and Discounted Revenue' do
    before :each do
      @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

      @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
      @discount2 = BulkDiscount.create!(merchant_id: 45, discount: 30, threshold: 10)
      @discount3 = BulkDiscount.create!(merchant_id: 45, discount: 50, threshold: 20)

      @customer1 = Customer.create!(id: 45, first_name:"John", last_name:"Doe")

      @item1 = Item.create!(id: 45, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant1.id)
      @item2 = Item.create!(id: 46, name:"Medium basket", description:"Blue and medium", unit_price: 1399, merchant_id: @merchant1.id)
      @item3 = Item.create!(id: 47, name:"Little basket", description:"Yellow and small", unit_price: 1199, merchant_id: @merchant1.id)

      @invoice1 = Invoice.create!(id: 45, customer_id: @customer1.id, status: 1)

      @invoice_item1 = InvoiceItem.create!(id: 45, item_id: @item1.id, invoice_id: @invoice1.id, quantity:1, unit_price:1499 , status: 0)
      @invoice_item19 = InvoiceItem.create!(id: 63, item_id: @item1.id, invoice_id: @invoice1.id, quantity:6, unit_price:1499 , status: 0)
      @invoice_item20 = InvoiceItem.create!(id: 64, item_id: @item1.id, invoice_id: @invoice1.id, quantity:17, unit_price:1499 , status: 0)
      @invoice_item21 = InvoiceItem.create!(id: 65, item_id: @item2.id, invoice_id: @invoice1.id, quantity:25, unit_price:1399 , status: 0)
      @invoice_item22 = InvoiceItem.create!(id: 66, item_id: @item3.id, invoice_id: @invoice1.id, quantity:1, unit_price:1199 , status: 0)
    end

    describe '.total_revenue' do
      it "Should return the total price of all items on an invoice" do
        expect(@invoice1.total_revenue).to eq(72150)
      end
    end

    describe '.total_discounted_revenue' do
      it 'should return the revenue on an invoice after all discounts have been applied' do
        expect(@invoice1.total_discounted_revenue).to eq(45219)
      end
    end
  end
end
