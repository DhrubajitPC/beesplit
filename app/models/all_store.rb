class AllStore < ActiveRecord::Base
  has_many :stores
  has_many :bees
end
