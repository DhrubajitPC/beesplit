class AllStore < ActiveRecord::Base
  has_many :stores
  has_many :bees
	
	accepts_nested_attributes_for :stores
end
