class CreateStore < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :item_id
      t.integer :all_store_id
      t.integer :stock

      t.timestamps null: false
    end
  end
end
