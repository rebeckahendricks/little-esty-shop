require 'rails_helper'

RSpec.describe 'As an admin,' do
  describe "When I visit an admin invoice show page" do
    before :each do
      visit admin_invoice_path(Invoice.first)
    end

    describe "links" do
      it "I see a header indicating that I am on the admin dashboard" do
        visit admin_invoice_path(Invoice.first)

        expect(page).to have_content "Admin Dashboard"
      end

      it "I see a link to the admin merchants index (/admin/merchants), and I can click said link to go to the correct path" do
        visit admin_invoice_path(Invoice.first)

        expect(page).to have_link("Dashboard")
        click_link "Dashboard"
        expect(page.current_path).to eq admin_index_path
      end

      it "I see a link to the admin merchants index (/admin/merchants), and I can click said link to go to the correct path" do
        visit admin_invoice_path(Invoice.first)

        expect(page).to have_link("Merchants")
        click_link "Merchants"
        expect(page.current_path).to eq admin_merchants_path
      end

      it "I see a link to the admin invoices index (/admin/invoices), and I can click said link to go to the correct path " do
        visit admin_invoice_path(Invoice.first)

        expect(page).to have_link("Invoices")
        click_link "Invoices"
        expect(page.current_path).to eq admin_invoices_path
      end
    end

    it "Then I see information related to that invoice including:
      - Invoice id
      - Invoice status
      - Invoice created_at date in the format 'Monday, July 18, 2019'
      - Customer first and last name" do

      expect(page).to have_content("Invoice ID: 1")
      expect(page).to have_content("cancelled")
      expect(page).to have_content("Created at: Sunday, March 25, 2012")
      expect(page).to have_content("Customer: Joey Ondricka")

      expect(page).to_not have_content("Cecelia Osinski")
      expect(page).to_not have_content("Invoice ID: 2")
    end

    it "Then I see all of the items on the invoice including:
      - Item name
      - The quantity of the item ordered
      - The price the Item sold for
      - The Invoice Item status" do

      expect(page).to have_content("Invoice Items")
      expect(page).to have_content("Item Qui Esse")
      expect(page).to have_content("Quantity: 5")
      expect(page).to have_content("Unit Price: $751.07")
      expect(page).to have_content("Status: shipped")

      expect(page).not_to have_content("Item Eos Quia")
      expect(page).not_to have_content("Packaged")
    end

    it "Then I see the total revenue that will be generated from this invoice" do
      expect(page).to have_content("Total Invoice Revenue: $23527.28")
    end

    it "I see the invoice status is a select field, And I see that the invoice's current status is selected" do
      # expect(page).to have_form("status")
      expect(page).to have_content("cancelled")
      #unsure how to check for select field, or preselected status
    end

    it "When I click this select field, Then I can select a new status for the Invoice,
      And next to the select field I see a button to Update Invoice Status
      When I click this button
      I am taken back to the admin invoice show page
      and I see that my Invoice's status has now been updated" do

      expect(page).to have_content("cancelled")
      expect(page).to have_button("Update Invoice Status")

      select('completed', from: 'invoice_status')

      click_button("Update Invoice Status")
      expect(current_path).to eq(admin_invoice_path(Invoice.first))
      expect(page).to have_content("Customer: Joey Ondricka")
      expect(page).to have_content("completed")

      # expect(page).to_not have_content("in_progress") must be in within block
      expect(page).to_not have_content("Cecelia Osinski")
    end

    describe 'Admin Invoice Show Page: Total Revenue and Discounted Revenue' do
      before :each do
        @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

        @customer1 = Customer.create!(id: 45, first_name:"John", last_name:"Doe")

        @item1 = Item.create!(id: 45, name:"Big basket", description:"Green and big", unit_price: 1499, merchant_id: @merchant1.id)
        @item2 = Item.create!(id: 46, name:"Medium basket", description:"Blue and medium", unit_price: 1399, merchant_id: @merchant1.id)
        @item3 = Item.create!(id: 47, name:"Little basket", description:"Yellow and small", unit_price: 1199, merchant_id: @merchant1.id)

        @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
        @discount2 = BulkDiscount.create!(merchant_id: 45, discount: 30, threshold: 10)
        @discount3 = BulkDiscount.create!(merchant_id: 45, discount: 50, threshold: 20)

        @invoice1 = Invoice.create!(id: 45, customer_id: @customer1.id, status: 1)

        @invoice_item1 = InvoiceItem.create!(id: 45, item_id: @item1.id, invoice_id: @invoice1.id, quantity:1, unit_price:1499 , status: 0)
        @invoice_item19 = InvoiceItem.create!(id: 63, item_id: @item1.id, invoice_id: @invoice1.id, quantity:6, unit_price:1199 , status: 0)
        @invoice_item20 = InvoiceItem.create!(id: 64, item_id: @item1.id, invoice_id: @invoice1.id, quantity:17, unit_price:1049 , status: 0)
        @invoice_item21 = InvoiceItem.create!(id: 65, item_id: @item2.id, invoice_id: @invoice1.id, quantity:25, unit_price:699 , status: 0)
        @invoice_item22 = InvoiceItem.create!(id: 66, item_id: @item3.id, invoice_id: @invoice1.id, quantity:1, unit_price:1199 , status: 0)
      end

      it 'I see the total revenue from this invoice (not including discounts)' do
        visit admin_invoice_path(@invoice1)

        expect(page).to have_content("Total Invoice Revenue: $721.50")
      end

      it 'I see the total discounted revenue from this invoice which includes bulk discounts in the calculation' do
        visit admin_invoice_path(@invoice1)

        expect(page).to have_content("Total Discounted Revenue: $452.00")
      end
    end
  end
end
