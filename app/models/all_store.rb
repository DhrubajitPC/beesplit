class AllStore < ActiveRecord::Base
  has_many :store
  has_many :bees
end
