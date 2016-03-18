class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|

      t.string :name, null: false
      t.string :price, null: false
      t.integer :quantity, null: false

      t.timestamps null: false
    end
  end
end
