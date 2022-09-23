require 'rails_helper'

RSpec.describe 'As an admin,' do
  describe "When I visit a merchant's admin show page" do
    it "I see the name of that merchant after clicking the merchant link on the index page" do
      visit admin_merchants_path

      within("#merchant_names") do
        expect(page).to have_link("Schroeder-Jerde")
        click_link "Schroeder-Jerde"
        expect(page.current_path).to eq admin_merchant_path("1")
      end

      expect(page).to have_content("Schroeder-Jerde")
      expect(page).to_not have_content("Ernser, Borer and Marks")
      expect(page).to_not have_content("Jones and Stokes")

      visit admin_merchants_path

      within("#merchant_names") do
        expect(page).to have_link("Ernser, Borer and Marks")
        click_link "Ernser, Borer and Marks"
        expect(page.current_path).to eq admin_merchant_path("30")
      end

      expect(page).to have_content("Ernser, Borer and Marks")
      expect(page).to_not have_content("Schroeder-Jerde")
      expect(page).to_not have_content("Jones and Stokes")
    end

    it "Then I see a link to update the merchant's information. When I click the link, then I am taken to a page to edit this merchant" do
      visit admin_merchants_path

      within("#merchant_names") do
        expect(page).to have_link("Schroeder-Jerde")
        click_link "Schroeder-Jerde"
        expect(page.current_path).to eq admin_merchant_path("1")
      end

      expect(page).to have_link("Update Merchant")
      click_link "Update Merchant"
      expect(page.current_path).to eq edit_admin_merchant_path(1)
    end
  end
end
