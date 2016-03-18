class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name, null:false
      t.string :price, null:false
      t.string :type, null: false
      t.integer :store_id, null:false
      t.timestamps null: false
    end
  end
end
