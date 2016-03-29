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
		puts params[:order_all][:orders_attributes]["0"][:quantity]
		params[:order_all][:orders_attributes].each do |order|
			if order[1][:quantity].to_i() <= 0
				@order_all.orders[order[0].to_i()].destroy #delete record to prevent redundant rows
			end
		end
		
    if @order_all.save
      flash[:notice] = "Sucessfully Added New Order!"
      redirect_to root_path
    else
      flash[:notice] = "Failure in Creating New Order!"
      render :new
    end
  end

  private

  def order_all_params
    params.require(:order_all).permit(:delivery_time, orders_attributes: [ :item_id, :quantity ])
  end
end