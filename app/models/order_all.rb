class OrderAll < ActiveRecord::Base
  has_many :orders
	belongs_to:bee

  accepts_nested_attributes_for :orders
end