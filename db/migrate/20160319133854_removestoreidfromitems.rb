class Removestoreidfromitems < ActiveRecord::Migration
  def change
    remove_column :items, :store_id, :integer
  end
end
