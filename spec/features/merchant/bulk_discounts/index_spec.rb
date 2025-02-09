require 'rails_helper'
require 'date'

RSpec.describe 'Merchant Bulk Discounts Index', type: :feature do
  describe 'As a merchant' do
    describe 'When I visit my bulk discounts index' do
      it 'I see a link to create a new discount' do
        visit merchant_bulk_discounts_path(Merchant.first)

        expect(page).to have_link("Create New Discount")
      end

      describe 'When I click this link' do
        it 'I am taken to a new page where I see a form to add a new bulk discount' do
          visit merchant_bulk_discounts_path(Merchant.first)

          click_link "Create New Discount"

          expect(current_path).to eq(new_merchant_bulk_discount_path(Merchant.first))
        end
      end
    end

    describe 'Merchant Bulk Discount Delete' do
      before :each do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

        @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
        @discount2 = BulkDiscount.create!(merchant_id: 45, discount: 30, threshold: 10)
        @discount3 = BulkDiscount.create!(merchant_id: 45, discount: 50, threshold: 20)
      end
      it 'Next to each bulk discount I see a link to delete it' do
        visit merchant_bulk_discounts_path(@merchant1)

        within "#discount_#{@discount1.id}" do
          expect(page).to have_link("Delete")
        end

        within "#discount_#{@discount2.id}" do
          expect(page).to have_link("Delete")
        end

        within "#discount_#{@discount3.id}" do
          expect(page).to have_link("Delete")
        end
      end

      describe 'When I click this link' do
        it 'I am redirected back to the bulk discounts index page and I no longer see that discount listed' do
          visit merchant_bulk_discounts_path(@merchant1)

          within "#discount_#{@discount1.id}" do
            click_link "Delete"
          end

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))

          expect(page).to_not have_content("Discount ##{@discount1.id}")
          expect(page).to_not have_content("20% off 5 items or more")

          within "#discount_#{@discount2.id}" do
            expect(page).to have_content("30% off 10 items or more")
          end

          within "#discount_#{@discount3.id}" do
            expect(page).to have_content("50% off 20 items or more")
          end
        end
      end
    end

    describe 'Deleting Discounts - Invoice_Item Unit Prices' do
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

      it 'When a bulk discount is deleted, the unit price of an invoice item is restored to its original price (if no other discounts apply)' do
        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '20')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '30')
        fill_in('Item Threshold', with: '10')
        click_button 'Create'

        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '50')
        fill_in('Item Threshold', with: '20')
        click_button 'Create'

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$11.99")
        end

        visit merchant_bulk_discounts_path(@merchant1)

        first(:link, "Delete").click

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item2.id}" do
          expect(page).to have_content("$14.99")
        end
      end

      it 'When a bulk discount is deleted, the unit price of an invoice item unit price changes to the next best discount' do
        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '50')
        fill_in('Item Threshold', with: '20')
        click_button 'Create'

        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '30')
        fill_in('Item Threshold', with: '10')
        click_button 'Create'

        visit new_merchant_bulk_discount_path(@merchant1)

        fill_in('Percent Discount', with: '20')
        fill_in('Item Threshold', with: '5')
        click_button 'Create'

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item4.id}" do
          expect(page).to have_content("$6.99")
        end

        visit merchant_bulk_discounts_path(@merchant1)

        first(:link, "Delete").click

        visit merchant_invoice_path(@merchant1, @invoice1)

        within "#price_#{@invoice_item4.id}" do
          expect(page).to have_content("$9.79")
        end
      end
    end

    describe 'Upcoming Holidays API' do
      it 'I see a section with a header of "Upcoming Holidays"' do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

        visit merchant_bulk_discounts_path(@merchant1)

        expect(page).to have_content("Upcoming Holidays")
      end

      it 'In the "Upcoming Holidays" section, I see the name and date of the next 3 upcoming US holidays' do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

        new_time = Time.local(2022, 9, 26, 12, 0, 0)
        Timecop.freeze(new_time)

        visit merchant_bulk_discounts_path(@merchant1)

        within "#upcoming_holidays" do
          expect(page).to have_content("Columbus Day: 2022-10-10")
          expect(page).to have_content("Veterans Day: 2022-11-11")
          expect(page).to have_content("Thanksgiving Day: 2022-11-24")
          expect(page).to_not have_content("Christmas Day: 2022-12-26")
        end
      end
    end
  end
end
