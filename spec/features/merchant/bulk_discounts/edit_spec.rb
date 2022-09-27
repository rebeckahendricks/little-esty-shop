require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Edit', type: :feature do
  describe 'As a merchant' do
    describe 'When I visit my bulk discount show page' do
      before :each do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

        @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
      end
      it 'I see a link to edit the bulk discount' do
        visit merchant_bulk_discount_path(@merchant1, @discount1)

        expect(page).to have_link("Edit Discount")
      end

      describe 'When I click this link' do
        it 'I am taken to a new page with a form to edit that discount' do
          visit merchant_bulk_discount_path(@merchant1, @discount1)

          click_link "Edit Discount"

          expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @discount1))
        end

        it 'I see that the discounts current attributes are pre-populated in the form' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          expect(page).to have_field('Percent Discount', with: '20')
          expect(page).to have_field('Item Threshold', with: '5')
        end
      end

      describe 'When I change any/all of the information and click submit' do
        it 'I am redirected to the bulk discounts show page' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          fill_in 'Percent Discount', with: '45'
          click_on "Submit"

          expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @discount1))
        end

        it 'I see that the discounts attributes have been updated' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          fill_in 'Percent Discount', with: '45'
          click_on "Submit"

          expect(page).to have_content("Percent Discount: 45% off")
          expect(page).to have_content("Item Threshold: 5 items or more")
          expect(page).to have_content("Discount successfully updated!")
        end
      end

      describe 'When I change all of the information and click submit' do
        it 'I am redirected to the bulk discounts show page' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          fill_in 'Percent Discount', with: '45'
          fill_in 'Item Threshold', with: '10'
          click_on "Submit"

          expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @discount1))
        end

        it 'I see that the discounts attributes have been updated' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          fill_in 'Percent Discount', with: '45'
          fill_in 'Item Threshold', with: '10'
          click_on "Submit"

          expect(page).to have_content("Percent Discount: 45% off")
          expect(page).to have_content("Item Threshold: 10 items or more")
          expect(page).to have_content("Discount successfully updated!")
        end
      end

      describe 'When I change some of the information to invalid information and click submit' do
        it 'I am redirected to the bulk discounts edit page and I see a message that says that my discount was not successfully updated' do
          visit edit_merchant_bulk_discount_path(@merchant1, @discount1)

          fill_in 'Percent Discount', with: ''
          fill_in 'Item Threshold', with: '10'
          click_on "Submit"

          expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant1, @discount1))
          expect(page).to have_content("Discount not updated: Missing required information.")
        end
      end
    end

    describe 'Updating Discounts - Invoice_Item Unit Prices' do
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

      it 'When I update a bulk discount, the unit price changes to reflect that discount' do
        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '20')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$11.99")
        end

        visit merchant_bulk_discounts_path(@merchant1)

        first(:link).click

        click_link "Edit Discount"

        fill_in 'Percent Discount', with: '30'
        fill_in 'Item Threshold', with: '5'
        click_on "Submit"

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$10.49")
        end
      end

      it 'When I update a bulk discount, and that discount no longer applies, the invoice_item unit_price is restored to its original state' do
        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '20')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$11.99")
        end

        visit merchant_bulk_discounts_path(@merchant1)

        first(:link).click

        click_link "Edit Discount"

        fill_in 'Percent Discount', with: '20'
        fill_in 'Item Threshold', with: '10'
        click_on "Submit"

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$14.99")
        end
      end

      it 'When I update a bulk discount, and that discount is no longer the best discount, the next best discount is applied to the invoice_item unit_price' do
        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '50')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '30')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$7.49")
        end

        visit merchant_bulk_discounts_path(@merchant1)

        first(:link).click

        click_link "Edit Discount"

        fill_in 'Percent Discount', with: '10'
        fill_in 'Item Threshold', with: '5'
        click_on "Submit"

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$10.49")
        end
      end
    end
  end
end
