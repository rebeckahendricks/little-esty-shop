require 'rails_helper'

RSpec.describe 'Merchant Bulk Discount Edit', type: :feature do
  before :each do
    @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

    @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
  end

  describe 'As a merchant' do
    describe 'When I visit my bulk discount show page' do
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
  end
end
