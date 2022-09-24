require 'rails_helper'

RSpec.describe 'Merchant Buld Discount Show', type: :feature do
  before :each do
    @merchant1 = Merchant.create!(id: 45, name:"Bob's Baskets")

    @discount1 = BulkDiscount.create!(merchant_id: 45, discount: 20, threshold: 5)
    @discount2 = BulkDiscount.create!(merchant_id: 45, discount: 30, threshold: 10)
  end

  describe 'As a merchant' do
    describe 'When I visit my bulk discount show page' do
      it 'I see the bulk discounts quantity threshold and percentage discount' do
        visit merchant_bulk_discount_path(@merchant1, @discount1)

        expect(page).to have_content("Discount ##{@discount1.id}")
        expect(page).to have_content("Percent Discount: 20% off")
        expect(page).to have_content("Item Threshold: 5 items or more")

        expect(page).to_not have_content("Discount ##{@discount2.id}")
        expect(page).to_not have_content("Percent Discount: 30% off")
        expect(page).to_not have_content("Item Threshold: 10 items or more")
      end
    end
  end
end
