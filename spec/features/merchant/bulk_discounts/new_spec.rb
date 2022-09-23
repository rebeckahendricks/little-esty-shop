require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Create', type: :feature do
  describe 'When I fill in the form with valid data' do
    it 'I am redirected back to the bulk discount index' do
      visit new_merchant_bulk_discount_path(Merchant.first)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      expect(current_path).to eq(merchant_bulk_discounts_path(Merchant.first))
    end

    it 'I see my new bulk discount listed' do
      visit new_merchant_bulk_discount_path(Merchant.first)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      expect(page).to have_content("45% off 10 items or more")
    end
  end
end
