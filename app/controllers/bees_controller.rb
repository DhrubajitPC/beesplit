class BeesController < ApplicationController

  def index

  end

  def show
    @bee = Bee.find(params[:id])
  end
	
	def resolve
		@bee = Bee.find(params[:id])
		@allstore = AllStore.find(@bee.all_store_id)
		OrderAll.where(:bee_id=>params[:id]).each do |order_all|
			order_all.orders.each do |order|
				@stock = @allstore.stores.find_by(item_id: order.item_id)
				@stock.stock -= order.quantity
				@stock.save
			end
			order_all.destroy
			order_all.save
		end
		@bee.status = 1
		@bee.save
		redirect_to store_path(@allstore.id)
	end
	
end