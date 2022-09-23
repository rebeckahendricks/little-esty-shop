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

    it 'I see my new bulk discount listed and I see a message that says "Discount created successfully!"' do
      visit new_merchant_bulk_discount_path(Merchant.first)

      fill_in('Percent Discount', with: '45')
      fill_in('Item Threshold', with: '10')
      click_button 'Create'

      expect(page).to have_content("45% off 10 items or more")
      expect(page).to have_content("Discount created successfully!")
    end
  end

  describe 'When I do not fill in all of the forms with valid data' do
    it 'I am redirected to the same page and I see a message that says "Discount not created: Missing required information."' do
      visit new_merchant_bulk_discount_path(Merchant.first)

      fill_in('Percent Discount', with: '45')
      #'Item Threshold' is not filled in
      click_button 'Create'

      expect(current_path).to eq(new_merchant_bulk_discount_path(Merchant.first))
      expect(page).to have_content("Discount not created: Missing required information.")
    end
  end
end
