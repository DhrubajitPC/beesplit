class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :quantity
      t.integer :item_id
      t.integer :bee_id
      t.integer :order_all_id
      t.datetime :delivery_time

      t.timestamps null: false
    end
  end
end
