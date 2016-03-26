class OrdersController < ApplicationController

  def new
    @order = Order.new
    @items = Item.all
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      flash[:notice] = "Added new order"
      redirect_to root_path
    else
      flash[:notice] = "Creating new order failed"
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:delivery_time, :quantity, :item_id, :order_all_id)
  end
end