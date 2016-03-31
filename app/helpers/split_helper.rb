module SplitHelper #Contains all key split (and combine) functions
	include ApplicationHelper
	
	@@qLowerBound = 8 #how many items is deemed 'too little?'
	@@qNormal = 20 #how many items are there in a typical order?
	@@qHigherBound = 35 #how many items is deemed 'too much?'
	@@storeDistMax = 5 #how far (based on levenshtein_distance) is too far?
	@@processNHoursAhead = 3.0 #how many hours from now would you like to process orders
	
	def splitMain
		@order_alls_tobe_combined = []
		@order_alls_tobe_split = []
		flash[:process] = ''
		#8.0 is to offset sg local time
		@order_alls_tobe_processed = OrderAll.where(:bee_id => nil).where("delivery_time <= :dt", {dt: DateTime.now + (8.0+@@processNHoursAhead/24)})
		@order_alls_tobe_processed.each do |order_all|
			#compute quantity and deem if it is necessary to make adjustments
			@total_q = 0
			order_all.orders.each do |order|
				@total_q += order.quantity
			end
			if (@total_q < 8)
				@order_alls_tobe_combined.push(order_all)
			elsif (@total_q>35)
				@order_alls_tobe_split.push(order_all)
			else
				assign_bee(order_all, find_best_bee(order_all))
			end
			puts @total_q
		end
		
		if(!@order_alls_tobe_combined.empty?) #combine if not empty
			combine(@order_alls_tobe_combined)
		end
		if(!@order_alls_tobe_split.empty?) #split if not empty
			split(@order_alls_tobe_split)
		end
		
		@order_alls_unprocessed = @order_alls_tobe_processed.where(:bee_id => nil)
		@order_alls_processed = @order_alls_tobe_processed - @order_alls_unprocessed
	end

	#returns a bee who is assigned at a store that can take the order.
	#if error, will return an error message string instead.
	def find_best_bee(order_all) #overload 1
		find_best_bee_ns(order_all, nearby_stores(order_all.address))
	end
	def find_best_bee_ns(order_all, nearby_stores) #overload 2 - predetermined nearby_stores
		@nearby_stores = nearby_stores
		
		if (@nearby_stores.empty?)
			return 'You live too far from our stores :('
		end
		
		@freeBees = Bee.where(status: 1, all_store_id: @nearby_stores.keys) #free
		@min = 99999
		@best_bee = nil
		@freeBees.each do |bee|
			if (store_has_enough_items(AllStore.find(bee.all_store_id), order_all))
				if (@nearby_stores[bee.all_store_id] < @min)
					@min = @nearby_stores[bee.all_store_id]
					@best_bee = bee
				end
			end
		end
		
		if (!@best_bee.nil?)
			return @best_bee
		else
			return 'Unable to find a bee (or a store) to take the order :('
		end
		
		return 'Unknown error.'
	end

	#Assigns a list of order_all (or an order_all) to a bee and update the status of the bee to be busy. Also append necessary process flash messages and handles error instances (assuming error bee are string messages)
	def assign_bee(order_all, bee)
		if (bee.instance_of? String)
			flash[:process] += '<li> Order_All #' + order_all.id.to_s + ': ' + bee + '</li>'
		else #if not string means no error
			if (order_all.kind_of?(Array))
				order_all.each do |orderall|
					orderall.bee_id = bee.id
					orderall.save
					flash[:process] += '<li>Order_All #' + orderall.id.to_s + ': Assigned bee #' + bee.id.to_s + '! :)' + '</li>'
				end
			else
				order_all.bee_id = bee.id
				order_all.save
				flash[:process] += '<li>Order_All #' + order_all.id.to_s + ': Assigned bee #' + bee.id.to_s + '! :)' + '</li>'
			end
			bee.status = 0
			bee.save
			flash[:process] += '<li>Updated bee #' + bee.id.to_s + '\'s status to busy! :)' + '</li>'
			flash[:process] += '<br/>'
		end
	end
	
	def combine(order_all_list)
		puts 'COMBINING'
		order_all_list.each do |order_all1|
			if (!order_all1.bee_id.nil?) #ensure this order has not been assigned to a bee
				next
			end
			@best_score = -99999
			@best_order_all = nil
			@best_order_bee = nil
			order_all_list.each do |order_all2| #try to match
				if (order_all1.id == order_all2.id or !order_all2.bee_id.nil?)
					next
				end
				@combine_score = 0
				@order_categories = [] #all item categories in an order
				@order_all = OrderAll.new #This will not be saved!
				order_all1.orders.each do |order|
					@order_all.orders.build(:item_id => order.item_id, :quantity => order.quantity)
					@combine_score -= 2 #to make sure order_all1 > order_all2 or order_all2 > order_all1 is still consistent
					@newcat = Item.find(order.item_id).category
					if (!@order_categories.include? @newcat)
						@order_categories.push(@newcat)
						@combine_score -= 1
					end
				end
				order_all2.orders.each do |order|
					#dirty record processing, cannot use where
					@order_line = nil
					@order_all.orders.each do |o|
						if (o.item_id == order.item_id)
							@order_line = o
						end
					end
					if (@order_line.nil?)
						@order_all.orders.build(:item_id => order.item_id, :quantity => order.quantity)
						@combine_score -= 2
						@newcat = Item.find(order.item_id).category
						if (!@order_categories.include? @newcat)
							@order_categories.push(@newcat)
							@combine_score -= 1
						end
					else
						@order_line.quantity += order.quantity
						@combine_score += 3
					end
				end
				@nearby_stores1 = nearby_stores(order_all1.address)
				@nearby_stores2 = nearby_stores(order_all2.address)
				@nearby_stores = nearby_stores_overlap(@nearby_stores1, @nearby_stores2)
				#checks if a bee can do this job, #ignore this solution if no bee is assigned
				@bee = find_best_bee_ns(@order_all, @nearby_stores) #only checks relevant nearby stores
				if (!@bee.instance_of? String)
					puts 'POTENTIAL'
					puts order_all1.id
					puts order_all2.id
					puts @combine_score
					puts 'END POTENTIAL'
					#scoring mechanism is determined by the extra 'items' and 'categories' introduced.
					if (@combine_score > @best_score)
						@best_score = @combine_score
						@best_order_all = [order_all1, order_all2]
						@best_order_bee = @bee
					end
				end
			end #end loop for order_all2
			if (@best_order_all.nil?)
				assign_bee(order_all1, find_best_bee(order_all1)) #if nil, treat as singular order
			else
				assign_bee(@best_order_all, @best_order_bee)
			end
		end
	end
	
	def split(order_all_list)
		puts 'SPLITTIN'
	end
	
	def nearby_stores(delivery_address)
		@stores = {}
		AllStore.all.each do |all_store|
			@dist = levenshtein_distance(all_store.address, delivery_address)
			if (@dist <= @@storeDistMax)
				@stores[all_store.id] = @dist
				puts all_store.address
			end
		end
		return @stores
	end
	
	def nearby_stores_overlap(ns1, ns2)
		@nearby_stores = {}
		ns1.keys.each do |key|
			if (ns2.has_key? key)
				if (ns1[key]>ns2[key])
					@nearby_stores[key] = ns1[key]
				else
					@nearby_stores[key] = ns2[key]
				end
			end
		end
		return @nearby_stores
	end
	
	def store_has_enough_items(all_store, order_all)
		#should try to take into account ongoing orders :|
		order_all.orders.each do |order|
			@available = false
			all_store.stores.each do |store_item|
				if (store_item.item_id == order.item_id)
					if (store_item.stock < order.quantity)
						return false
					else
						@available = true
					end
				end
			end
			if (!@available)
				return false
			end
		end
		return true
	end
	
end
