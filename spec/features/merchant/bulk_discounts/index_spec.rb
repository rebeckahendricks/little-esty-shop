require 'rails_helper'

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
  end
end
