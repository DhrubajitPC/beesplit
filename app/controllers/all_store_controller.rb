class AllStoreController < ApplicationController
  def index
    @all_stores = AllStore.all
  end
end