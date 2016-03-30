module SplitHelper #Contains all key split (and combine) functions
	include ApplicationHelper
	
	@qLowerBound = 8 #how many items is deemed 'too little?'
	@qNormal = 20 #how many items are there in a typical order?
	@qHigherBound = 35 #how many items is deemed 'too much?'
	@storeDistMax = 5 #how far (based on levenshtein_distance) is too far?
	
	def splitMain
		OrderAll.where(:bee_id => nil).each do |order_all|
			#compute quantity and deem if it is necessary to make adjustments
			@total_q = 0
			order_all.orders.each do |order|
				@total_q += order.quantity
			end
			if (@total_q < 8)
				combine()
			elsif (@total_q>35)
				split()
			else
				assign(order_all)
			end
		end		
	end

	def assign(order_all)
		@nearby_stores = nearby_stores(order_all.address)
	
		@freeBees = Bee.where(status: 1, all_store_id: @nearby_stores.keys) #free
		@min = 99999
		@best_bee = nil
		@freeBees.each do |bee|
			if (@nearby_stores[bee.all_store_id] < @min)
				@min = @nearby_stores[bee.all_store_id]
				@best_bee = bee
			end
		end
		
		order_all.bee_id = @best_bee.id
		order_all.update
		
		puts @best_bee.name
		puts @min
	end
	
	def nearby_stores(delivery_address)
		@stores = {}
		AllStore.all.each do |all_store|
			@dist = levenshtein_distance(all_store.address, delivery_address)
			if (@dist <= @storeDistMax)
				@stores[all_store.id] = @dist
				puts all_store.name
			end
		end
		return @stores
	end
	
end
