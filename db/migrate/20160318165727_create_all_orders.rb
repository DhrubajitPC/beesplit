class CreateAllOrders < ActiveRecord::Migration
  def change
    create_table :all_orders do |t|

      t.timestamps null: false
    end
  end
end
