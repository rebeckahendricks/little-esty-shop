require 'rails_helper'

RSpec.describe 'Merchant Items Index Page' do
  describe 'As a merchant' do
    describe 'When I visit my merchant items index page ("merchants/merchant_id/items")' do
      it 'I see a list of the names of all of my items' do
        visit merchant_items_path(Merchant.first)

          expect(page).to have_content("Item Qui Esse")
          expect(page).to have_content("Item Autem Minima")
          expect(page).to have_content("Item Ea Voluptatum")
      end

      it 'I do not see items for any other merchant' do
        visit merchant_items_path(Merchant.first)

          expect(page).to_not have_content("Item Nemo Facere")
          expect(page).to_not have_content("Item Expedita Aliquam")
          expect(page).to_not have_content("Item Provident At")
          expect(page).to_not have_content("Item Itaque Consequatur")
      end

      it 'has two sections, one for "Enabled Items"  and one for "Disabled Items"' do 
        visit merchant_items_path(Merchant.first)

          expect(page).to have_content("Enabled Items")
          expect(page).to have_content("Disabled Items")

        within "div#Disabled_Items" do
          expect(page).to have_content("Autem Minima")
          expect(page).to have_content("Ea Voluptatum")
          expect(page).to have_content("Item Qui Esse")
        end

        find("div#1").click_button("enable")

        within "div#Enabled_Items" do
          expect(page).to have_content("Item Qui Esse")
          expect(page).to_not have_content("Ea Voluptatum")
          expect(page).to_not have_content("Item Qui Esse")
        end

        within "div#Disabled_Items" do
          expect(page).to have_content("Autem Minima")
          expect(page).to have_content("Ea Voluptatum")
          expect(page).to_not have_content("Item Qui Esse")
        end
      end
    end
  end
end
