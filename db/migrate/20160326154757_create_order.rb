class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :quantity
      t.integer :item_id
      t.integer :order_all_id

      t.timestamps null: false
    end
  end
end
