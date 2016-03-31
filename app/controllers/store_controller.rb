class StoreController < ApplicationController
  def show
    @store = AllStore.find(params[:id])
    # byebug
  end
end