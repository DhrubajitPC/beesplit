# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

3.times do
  AllStore.create!(
    address: Faker::Address.street_address
  )
end

4.times do
  Bee.create!(
      name: Faker::Name.name,
      contact: Faker::PhoneNumber.cell_phone,
      email: Faker::Internet.email,
      status: rand(0..2),
      all_store_id: rand(1..2)
  )
end

10.times do
  Item.create!(
     name: Faker::Commerce.product_name,
     price: Faker::Commerce.price,
     category: Faker::Commerce.department(1),
  )
end

4.times do
  Store.create!(
    item_id: rand(1..9),
    all_store_id: rand(1..2),
    stock: rand(1..50)
  )
end

22.times do
  Order.create!(
    quantity: rand(1..9),
    item_id: rand(1..10),
    order_all_id: rand(1..8)
  )
end

8.times do
  OrderAll.create!(
		bee_id: rand(1..4),
		address: Faker::Address.street_address,
		delivery_time: Faker::Time.forward(2, :morning)
	)
end
