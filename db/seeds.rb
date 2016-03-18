# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

4.times do
  Bee.create!(
      name: Faker::Name.name,
      contact_no: Faker::PhoneNumber.cell_phone,
      email: Faker::Internet.email,
      status: 3
  )
end

10.times do
  Item.create!(
     name: Faker::Commerce.product_name,
     price: Faker::Commerce.price,
     category: Faker::Commerce.department(1),
     store_id: 1
  )
end

4.times do
  AllOrder.create!()
end

4.times do
  Store.create!(
    item_id: rand(1..10),
    all_store_id: rand(1..3),
    stock: rand(1..50)
  )
end

4.times do
  Order.create!(
    quantity: rand(1..10),
    item_id: rand(1..10),
    all_order_id: rand(1..4)
  )
end

3.times do
  AllStore.create!(
    address: Faker::Address.street_address
  )
end
