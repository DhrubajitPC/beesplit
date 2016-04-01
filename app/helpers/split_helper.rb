module SplitHelper #Contains all key split (and combine) functions
	include ApplicationHelper
	
	@@qLowerBound = 8 #how many items is deemed 'too little?'
	@@qNormal = 20 #how many items are there in a typical order?
	@@qHigherBound = 35 #how many items is deemed 'too much?'
	@@storeDistMax = 6 #how far (based on levenshtein_distance) is too far?
	@@processNHoursAhead = 3.0 #how many hours from now would you like to process orders
	
	def splitMain
		@order_alls_tobe_combined = []
		@order_alls_tobe_split = []
		flash[:process] = ''
		#8.0 is to offset sg local time
		@order_alls_tobe_processed = OrderAll.where(:bee_id => nil).where("delivery_time <= :dt", {dt: DateTime.now + (8.0+@@processNHoursAhead/24)})
		#ignore parent orders (splitted orders)
		@parent_oa_ids = OrderAll.select("parent_id").where.not(:parent_id=>nil).map(&:parent_id).uniq
		puts @parent_oa_ids
		@order_alls_tobe_processed = @order_alls_tobe_processed.where.not(:id=>@parent_oa_ids)
		
		@order_alls_tobe_processed.each do |order_all|
			#compute quantity and deem if it is necessary to make adjustments
			@total_q = 0
			order_all.orders.each do |order|
				@total_q += order.quantity
			end
			if (@total_q < 8)
				@order_alls_tobe_combined.push(order_all)
			elsif (@total_q>35)
				@order_alls_tobe_split.push([order_all, @total_q])
			else
				assign_bee(order_all, find_best_bee(order_all))
				flash[:process] += '<br/>'
			end
			puts @total_q
		end
		
		if(!@order_alls_tobe_combined.empty?) #combine if not empty
			combine(@order_alls_tobe_combined)
		end
		@successful_split_ids = []
		if(!@order_alls_tobe_split.empty?) #split if not empty
			@successful_split_ids = split(@order_alls_tobe_split)
		end
		
		#take into account splitted order_alls
		puts @successful_split_ids
		@order_alls_unprocessed = @order_alls_tobe_processed.where(:bee_id => nil).where.not(:id => @successful_split_ids)
		@order_alls_processed = @order_alls_tobe_processed - @order_alls_unprocessed + OrderAll.where(:parent_id => @successful_split_ids)
	end

	#returns a bee who is assigned at a store that can take the order.
	#if error, will return an error message string instead.
	def find_best_bee(order_all) #overload 1
		find_best_bee_ns(order_all, nearby_stores(order_all.address))
	end
	def find_best_bee_ns(order_all, nearby_stores) #overload 2 - predetermined nearby_stores
		@freeBees = Bee.where(status: 1, all_store_id: nearby_stores.keys) #free
		find_best_bee_bns(order_all, nearby_stores, @freeBees)
	end
	def find_best_bee_bns(order_all, nearby_stores, free_bees) #overload 3 - predetermined free bees
		@nearby_stores = nearby_stores
		
		if (@nearby_stores.empty?)
			return 'You live too far from our stores :('
		end
		
		@freeBees = free_bees
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
		end
	end
	
	#success is indicated by returning true
	def assign_multiple_bees(order_all, child_oa_list, bee_list)
		if (bee_list.length == child_oa_list.length) #success
			flash[:process] += '<li>Splitting Order #' + order_all.id.to_s + '!' + '</li>'
			child_oa_list.each do |child_order|
				if (child_order[0].orders.length > 0)
					assign_bee(child_order[0], bee_list[child_order[0]])
				end
			end
			flash[:process] += '<br/>'
			#order_all.bee_id = 0 #bee_id 0 means its assigned to child
			#order_all.save
			return true
		end
		return false
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
				flash[:process] += '<br/>'
			else
				assign_bee(@best_order_all, @best_order_bee)
				flash[:process] += '<br/>'
			end
		end
	end
	
	def split(order_all_list)
		puts 'SPLITTIN'
		@successful_split_ids = []
		order_all_list.each do |order_all_arr| #this is in form of [order_all, quantity]			
			@order_all = order_all_arr[0]
			@n_splits = (order_all_arr[1]/@@qNormal).ceil #number of child order_alls created
			#Sanity Check: Enough free bees?
			@nearby_stores = nearby_stores(@order_all.address)
			@freeBees = Bee.where(status: 1, all_store_id: @nearby_stores.keys) #free
			if (@freeBees.length < @n_splits)
				#skip
				assign_bee(@order_all, 'Your order is so large we don\'t have enough free bees atm D:')
				flash[:process] += '<br/>'
				next
			end
			
			@child_orders = []
			for i in 1..@n_splits
				#[child order_all to be saved, categories, quantity]
				@child_orders.push([OrderAll.new, [], 0])
				@child_orders[i-1][0].parent_id = @order_all.id
				@child_orders[i-1][0].address = @order_all.address
				@child_orders[i-1][0].delivery_time = @order_all.delivery_time
			end
			#Initial: Split orders by Category
			@order_all.orders.each do |order|
				@newcat = Item.find(order.item_id).category
				@done = false
				@child_orders.each do |child_order|
					if (child_order[1].include? @newcat and !@done and child_order[2]<@@qHigherBound)
						child_order[0].orders.build(:item_id => order.item_id, :quantity => order.quantity)
						child_order[1].push(@newcat)
						child_order[2] += order.quantity
						@done = true
					end
				end
				if (!@done)
					@co_counter = 0 #new category goes into child order_all with least quantity
					@min = @child_orders[0][2]
					for z in 1..@n_splits-1
						if (@child_orders[z][2]<@min)
							@co_counter = z
							@min = @child_orders[z][2]
						end
					end
					@child_orders[@co_counter][0].orders.build(:item_id => order.item_id, :quantity => order.quantity)
					@child_orders[@co_counter][1].push(@newcat)
					@child_orders[@co_counter][2] += order.quantity
				end
			end
			#Store Sanity Check: Stock vs Order Quantity per child order issues
			@bee_list = {}
			@ns = @nearby_stores.clone #clone
			@fb = @freeBees - Bee.where(:id => -1)
			
			puts '----------'
			@a = (0..@child_orders.length-1).to_a
			@a_permutations = @a.permutation.to_a
			@success = false
			@a_permutations.each do |_a| #try all splitting permutation to find answer
				puts '----------'
				_a.each do |i|
					puts i
					@child_order = @child_orders[i]
					puts @child_order[0].orders
					if (@child_order[0].orders.length <= 0)
						@bee_list[@child_order[0]] = 'Nobody' #empty child_order
						next
					end
					@bee = find_best_bee_bns(@child_order[0], @ns, @fb)
					if (@bee.instance_of? String) #cannot find bee to be assigned
						@bee_list = {}
						break
					else
						@fb = @fb - Bee.where(:id => @bee.id) #remove bee from pool
						@bee_list[@child_order[0]] = @bee
					end
				end #_a.each do |i|
				
				if assign_multiple_bees(@order_all, @child_orders, @bee_list)
					@successful_split_ids.push(@order_all.id)
					@success = true
					break
				end
			end
			
			if (@success) #skip
				next
			end
			# @child_orders.each do |child_order|
				# puts child_order[0].orders
				# if (child_order[0].orders.length <= 0)
					# @bee_list[child_order[0]] = 'Nobody' #empty child_order
					# next
				# end
				# @bee = find_best_bee_bns(child_order[0], @ns, @fb)
				# if (@bee.instance_of? String) #cannot find bee to be assigned
					# @bee_list = {}
					# break
				# else
					# @fb = @fb - Bee.where(:id => @bee.id) #remove bee from pool
					# @bee_list[child_order[0]] = @bee
				# end
			# end
			# if assign_multiple_bees(@order_all, @child_orders, @bee_list)
				# @successful_split_ids.push(@order_all.id)
				# next
			# end
			
			#if not successful, we have to split the order lines...
			
			assign_bee(@order_all, 'I give up processing your order... :\'(')
			flash[:process] += '<br/>'
		end
		return @successful_split_ids
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
