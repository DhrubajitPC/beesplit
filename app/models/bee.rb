class Bee < ActiveRecord::Base
  has_many :order_alls
  belongs_to :all_store

  enum status: [:busy, :free, :unavailable]
end
