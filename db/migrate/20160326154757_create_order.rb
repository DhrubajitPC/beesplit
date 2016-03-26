class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :quantity
      t.integer :item_id
      t.integer :bee_id
      t.datetime :delivery_time
    end
  end
end
