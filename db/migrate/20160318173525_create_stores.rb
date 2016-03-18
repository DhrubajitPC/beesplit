class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :item_id, null: false
      t.integer :all_store_id, null:false
      t.string :stock, default: false


      t.timestamps null: false
    end
  end
end
