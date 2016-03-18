class Store < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :all_store
end
