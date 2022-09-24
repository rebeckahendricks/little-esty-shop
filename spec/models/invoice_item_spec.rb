require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
  end

  describe 'validations' do
    it { should validate_presence_of(:item_id) }
    it { should validate_presence_of(:invoice_id) }
    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:status) }
  end

  describe 'class methods' do
    describe '.for_merchant' do
      it 'can list all of merchants specific items that are on a invoice' do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")
        @merchant2 = Merchant.create!(id: 46, name:"Sue's Sandals")

        @customer1 = Customer.create!(id: 45, first_name:"John", last_name:"Doe")

        @item1 = Item.create!(id: 45, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant1.id)
        @item2 = Item.create!(id: 46, name:"Medium basket", description:"Blue and medium", unit_price: 1399, merchant_id: @merchant2.id)

        @invoice1 = Invoice.create!(id: 45, customer_id: @customer1.id, status: 1)

        @invoice_item1 = InvoiceItem.create!(id: 45, item_id: @item1.id, invoice_id: @invoice1.id, quantity:1, unit_price:1499 , status: 0)
        @invoice_item2 = InvoiceItem.create!(id: 46, item_id: @item2.id, invoice_id: @invoice1.id, quantity:2 , unit_price:1399 , status: 1)

        expect(described_class.for_merchant(@merchant1.id).first.item.name).to eq("Big basket")
      end
    end
  end

  describe 'instance methods' do
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

    describe '.discounted_price(percent_discount)' do
      it 'can calculate a discounted unit price given a percent discount' do
        expect(@invoice_item1.discounted_price(20)).to eq(1199.2)
        expect(@invoice_item19.discounted_price(50)).to eq(749.5)
        expect(@invoice_item20.discounted_price(90)).to eq(149.9)
      end
    end
  end
end
