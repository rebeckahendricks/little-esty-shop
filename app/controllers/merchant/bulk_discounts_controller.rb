class Merchant::BulkDiscountsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
  end

  def new
    @bulk_discount = BulkDiscount.new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.new(bulk_discount_params)
    if @bulk_discount.save
      redirect_to merchant_bulk_discounts_path(@merchant), notice: "Discount created successfully!"
    else
      redirect_to new_merchant_bulk_discount_path(@merchant), notice: "Discount not created: Missing required information."
    end
  end

  def bulk_discount_params
    params.require(:bulk_discount).permit(:discount, :threshold, :merchant_id)
  end
end
