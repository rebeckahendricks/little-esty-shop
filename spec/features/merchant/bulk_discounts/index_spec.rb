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
  end
end
