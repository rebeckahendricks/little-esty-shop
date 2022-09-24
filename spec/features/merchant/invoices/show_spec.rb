require 'rails_helper'

RSpec.describe 'Merchant Invoices Show Page' do
  describe 'As a merchant' do
    describe 'When I visit my merchant invoices show page' do
      it 'Then I see information related to that invoice' do
        @merchant = Merchant.first
        invoice_1 = @merchant.invoices.first
        invoice_2 = @merchant.invoices.last

        visit merchant_invoice_path(@merchant, invoice_1)

          expect(page).to have_content("Invoice ID: 1")
          expect(page).to have_content("Invoice Status: cancelled")
          expect(page).to have_content("Invoice Date: Sunday, March 25, 2012")
          expect(page).to have_content("Invoice Customer Name: Joey Ondricka")
          expect(page).to_not have_content("Invoice ID: 5")
      end

      it 'I see all of my items on the invoice including the name' do
        @merchant = Merchant.first
        invoice_1 = @merchant.invoices.first

        visit merchant_invoice_path(@merchant, invoice_1)

        within "#name_#{invoice_1.invoice_items.first.id}" do
          expect(page).to have_content("Item Qui Esse")
        end

        within "#quantity_#{invoice_1.invoice_items.first.id}" do
          expect(page).to have_content("5")
        end

        within "#price_#{invoice_1.invoice_items.first.id}" do
          expect(page).to have_content("$136.35")
        end

        expect(page).to_not have_content("Item Name: Item Expedita Aliquam")
        expect(page).to_not have_content("Item Name: Provident At")
      end

      it 'I see the total revenue that will be generated from all of my items on the invoice' do
        @merchant = Merchant.first
        invoice_1 = @merchant.invoices.first

        visit merchant_invoice_path(@merchant, invoice_1)

        expect(page).to have_content("Total Revenue: $23527.28")
      end

      it 'I see that each invoice item status is a select field and I see that the invoice items current status is selected' do
        @merchant = Merchant.first
        invoice_1 = @merchant.invoices.first

        visit merchant_invoice_path(@merchant, invoice_1)

        within "#status_#{invoice_1.invoice_items.first.id}" do
          expect(page).to have_select('status'), 'packaged'
        end
      end

      describe 'When I click this select field' do
        it 'I can select a new status for the Item' do
          @merchant = Merchant.first
          invoice_1 = @merchant.invoices.first

          visit merchant_invoice_path(@merchant, invoice_1)

          within "#status_#{invoice_1.invoice_items.first.id}" do
            select :shipped, from: 'status'

            expect(page).to have_select('status'), 'shipped'
          end
        end

        it 'next to the select field I see a button to "Update Item Status"' do
          @merchant = Merchant.first
          invoice_1 = @merchant.invoices.first

          visit merchant_invoice_path(@merchant, invoice_1)

          within "#status_#{invoice_1.invoice_items.first.id}" do
            expect(page).to have_button('Update Item Status')
          end
        end

        describe 'When I click this button' do
          it 'I am taken back to the merchant invoice show page' do
            @merchant = Merchant.first
            invoice_1 = @merchant.invoices.first

            visit merchant_invoice_path(@merchant, invoice_1)

            within "#status_#{invoice_1.invoice_items.first.id}" do
              select :shipped, from: 'status'
              click_button 'Update Item Status'
              expect(current_path).to eq(merchant_invoice_path(@merchant, invoice_1))
            end
          end

          it 'I see that my Items status has now been updated' do
            @merchant = Merchant.first
            invoice_1 = @merchant.invoices.first

            visit merchant_invoice_path(@merchant, invoice_1)

            within "#status_#{invoice_1.invoice_items.first.id}" do
              select :shipped, from: 'status'
              click_button 'Update Item Status'
              expect(page).to have_select('status'), 'shipped'
            end
          end
        end
      end

      describe 'Bulk Discounts' do
        before :each do
            @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

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

        it 'I see that total discounted revenue for my merchant from this invoice which includes bulk discounts in the calculation' do
          visit merchant_invoice_path(@merchant1, @invoice1)

          expect(page).to have_content("Total Discounted Revenue: $721.50")
        end

        it 'Next to each invoice item I see a link to the show page for the bulk discount that was applied (if any)' do
          visit new_merchant_bulk_discount_path(@merchant1)

          fill_in('Percent Discount', with: '20')
          fill_in('Item Threshold', with: '5')
          click_button 'Create'

          visit new_merchant_bulk_discount_path(@merchant1)

          fill_in('Percent Discount', with: '50')
          fill_in('Item Threshold', with: '20')
          click_button 'Create'

          visit merchant_invoice_path(@merchant1, @invoice1)

          within "#discount_#{@invoice_item1.id}" do
            expect(page).to_not have_link("Discount Details")
          end

          within "#discount_#{@invoice_item19.id}" do
            expect(page).to have_link("Discount Details")
            click_link "Discount Details"
          end

          expect(page).to have_content("Percent Discount: 20% off")
          expect(page).to have_content("Item Threshold: 5 items or more")

          visit merchant_invoice_path(@merchant1, @invoice1)

          within "#discount_#{@invoice_item19.id}" do
            expect(page).to have_link("Discount Details")
            click_link "Discount Details"
          end

          expect(page).to have_content("Percent Discount: 50% off")
          expect(page).to have_content("Item Threshold: 20 items or more")
        end
      end
    end
  end
end
