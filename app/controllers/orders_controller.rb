class OrdersController < ApplicationController

  def new
    @order_all = OrderAll.new
    @items = Item.all
		@items.each do |item|
			@order_all.orders.build(:item_id => item.id) #prepopulate item id
		end
  end

  def create
		#flash[:notice] = "asdf"
		#@test = params[:new_order_all][:orders_attributes]
		#flash[:notice] = @test.to_str()
    @order_all = OrderAll.new(order_all_params)
		@orders = Array.new()
		params[:order_all][:orders_attributes].each do |order|
			puts 'DEBUGGING'
			puts order
			puts 'DEBUGGING'
			puts order.item_id
			puts order.quantity
			puts 'END DEBUGGING'
			if order[2] > ""
				if order[:quantity].to_i() > 0
					@orders.push(order)
				end
			end
		end
    if @order_all.save
      flash[:notice] = "Added new order"
      redirect_to root_path
    else
      flash[:notice] = "Creating new order failed"
      render :new
    end
  end

  private

  def order_all_params
    params.require(:order_all).permit(:delivery_time, orders_attributes: [ :item_id, :quantity ])
  end
end