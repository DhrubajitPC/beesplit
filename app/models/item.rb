class Item < ActiveRecord::Base
  belongs_to :orders
  belongs_to :stores
end
