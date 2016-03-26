class CreateOrderAll < ActiveRecord::Migration
  def change
    create_table :order_alls do |t|

      t.timestamps null: false
    end
  end
end
