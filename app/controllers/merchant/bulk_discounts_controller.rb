class Merchant::BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def new
    @bulk_discount = BulkDiscount.new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new(bulk_discount_params)
    @invoice_items = @merchant.invoice_items
    if @bulk_discount.save
      # @invoice_items.each do |invoice_item|
      #   if bulk_discount_params[:threshold].to_i >= invoice_item.quantity
      #     invoice_item.update(unit_price: invoice_item.discounted_price(bulk_discount_params[:discount].to_i))
      #   end
      # end
      redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount created successfully!"
    else
      redirect_to new_merchant_bulk_discount_path(@merchant), notice: "Discount not created: Missing required information."
    end
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    @merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.find(params[:id])
    if bulk_discount.update(bulk_discount_params)
      redirect_to merchant_bulk_discount_path(@merchant, bulk_discount), notice: "Discount successfully updated!"
    else
      redirect_to edit_merchant_bulk_discount_path(@merchant, bulk_discount), notice: "Discount not updated: Missing required information."
    end
  end

  def destroy
    @merchant = Merchant.find(params[:merchant_id])
    BulkDiscount.find(params[:id]).destroy
    redirect_to merchant_bulk_discounts_path(@merchant)
  end

  def bulk_discount_params
    params.require(:bulk_discount).permit(:discount, :threshold, :merchant_id)
  end
end
