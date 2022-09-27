require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Create', type: :feature do
  describe 'When I fill in the form with valid data' do
    before :each do
      @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")
    end
    it 'I am redirected back to the bulk discount index' do
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
    end

    it 'I see my new bulk discount listed and I see a message that says "Discount created successfully!"' do
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      expect(page).to have_content("45% off 10 items or more")
      expect(page).to have_content("Discount created successfully!")
    end
  end

  describe 'When I do not fill in all of the forms with valid data' do
    it 'I am redirected to the same page and I see a message that says "Discount not created: Missing required information."' do
      @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: "")
      click_button 'Create'

      expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
      expect(page).to have_content("Discount not created: Missing required information.")
    end
  end

  describe 'Bulk Discount Updates Unit Price' do
    before :each do
      @customer1 = Customer.create!(id: 45, first_name:"John", last_name:"Doe")

      @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

      @item1 = Item.create!(id: 45, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant1.id)
      @item2 = Item.create!(id: 46, name:"Medium basket", description:"Blue and medium", unit_price: 1399, merchant_id: @merchant1.id)

      @invoice1 = Invoice.create!(id: 45, customer_id: @customer1.id, status: 1)

      @invoice_item1 = InvoiceItem.create!(id: 45, item_id: @item1.id, invoice_id: @invoice1.id, quantity:1, unit_price:1499 , status: 0)
      @invoice_item2 = InvoiceItem.create!(id: 63, item_id: @item1.id, invoice_id: @invoice1.id, quantity:6, unit_price:1499 , status: 0)
      @invoice_item3 = InvoiceItem.create!(id: 64, item_id: @item1.id, invoice_id: @invoice1.id, quantity:17, unit_price:1499 , status: 0)
      @invoice_item4 = InvoiceItem.create!(id: 65, item_id: @item2.id, invoice_id: @invoice1.id, quantity:25, unit_price:1399 , status: 0)
    end

    it 'When no items have discounts applied, the discount applies to only items that meet the threshold' do
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '30')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      visit merchant_invoice_path(@merchant1, @invoice1)

      within "#price_#{@invoice_item1.id}" do
        expect(page).to have_content("$14.99")
      end

      within "#price_#{@invoice_item2.id}" do
        expect(page).to have_content("$14.99")
      end

      within "#price_#{@invoice_item3.id}" do
        expect(page).to have_content("$10.49")
      end

      within "#price_#{@invoice_item4.id}" do
        expect(page).to have_content("$9.79")
      end
    end

    it 'When a lower discount is created, it does not override previous a higher discount' do
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '30')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '20')
      fill_in('Item Threshold', with: '5')
      click_button 'Create'

      visit merchant_invoice_path(@merchant1, @invoice1)

      within "#price_#{@invoice_item1.id}" do
        expect(page).to have_content("$14.99")
      end

      within "#price_#{@invoice_item2.id}" do
        expect(page).to have_content("$11.99")
      end

      within "#price_#{@invoice_item3.id}" do
        expect(page).to have_content("$10.49")
      end

      within "#price_#{@invoice_item4.id}" do
        expect(page).to have_content("$9.79")
      end
    end

    it 'When a higher discount is created, it overrides a previous discount (if the quantity reaches the threshold)' do
      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '30')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '20')
      fill_in('Item Threshold', with: '5')
      click_button 'Create'

      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '50')
      fill_in('Item Threshold', with: '20')
      click_button 'Create'

      visit merchant_invoice_path(@merchant1, @invoice1)

      within "#price_#{@invoice_item1.id}" do
        expect(page).to have_content("$14.99")
      end

      within "#price_#{@invoice_item2.id}" do
        expect(page).to have_content("$11.99")
      end

      within "#price_#{@invoice_item3.id}" do
        expect(page).to have_content("$10.49")
      end

      within "#price_#{@invoice_item4.id}" do
        expect(page).to have_content("$6.99")
      end
    end

    it 'When a discount is applied for one merchant, it should not affect another merchants invoice' do
      @merchant2 = Merchant.create!(id: 46, name:"Porter's Pants")
      @customer2 = Customer.create!(id: 46, first_name:"Becka", last_name:"Whitehall")
      @item3 = Item.create!(id: 47, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant2.id)
      @invoice2 = Invoice.create!(id: 46, customer_id: @customer2.id, status: 1)
      @invoice_item5 = InvoiceItem.create!(id: 66, item_id: @item3.id, invoice_id: @invoice2.id, quantity:6, unit_price:1499 , status: 0)

      visit new_merchant_bulk_discount_path(@merchant1)

      fill_in('Percent Discount', with: '30')
      fill_in('Item Threshold', with: '5')
      click_button 'Create'

      visit merchant_invoice_path(@merchant2, @invoice2)

      within "#price_#{@invoice_item5.id}" do
        expect(page).to have_content("$14.99")
      end
    end
  end
end
