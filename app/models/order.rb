class Order < ActiveRecord::Base
  belongs_to :order_all
	belongs_to :item
end
