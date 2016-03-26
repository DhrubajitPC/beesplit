class CreateBee < ActiveRecord::Migration
  def change
    create_table :bees do |t|
      t.integer :order_id
      t.string :rating
      t.integer :status
      t.string :name
      t.string :email
      t.string :contact
      t.integer :all_store_id
    end
  end
end
