class OrdersController < ApplicationController
  def new
    @order = Order.new
    @items = Item.all
  end

  def create
    puts params
    # byebug
  end
end