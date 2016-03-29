class CreateOrderAll < ActiveRecord::Migration
  def change
    create_table :order_alls do |t|

			t.integer :bee_id
			t.datetime :delivery_time
      t.timestamps null: false
    end
  end
end
