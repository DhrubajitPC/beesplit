# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


for i in 1..10
  Bee.create!(
      name: Faker::Name.name,
      contact: Faker::PhoneNumber.cell_phone,
      email: Faker::Internet.email,
      status: i<9? 1 : 2,
      all_store_id: rand(1..3)
  )
end

for i in 1..10
  Item.create!(
     name: Faker::Commerce.product_name,
     price: Faker::Commerce.price,
     category: i<4? "Alpha": i<8? "Beta" : "Gamma",
  )
end

for i in 1..3
	for j in 1..10
		Store.create!(
			item_id: j,
			all_store_id: i,
			stock: rand(20..30)
		)
	end
end

AllStore.create!(
	address: "8 Somapah Road"
)
AllStore.create!(
	address: "2 Alexpah Road"
)
AllStore.create!(
	address: "2 Alexandra Road"
)

# 22.times do
  # Order.create!(
    # quantity: rand(1..9),
    # item_id: rand(1..10),
    # order_all_id: rand(1..6)
  # )
# end

# 6.times do
  # OrderAll.create!(
		# parent_id: nil,
		# bee_id: rand(1..8),
		# address: rand(1..999).to_s + " Somapah Road",
		# delivery_time: Faker::Time.forward(2, :morning)
	# )
# end
