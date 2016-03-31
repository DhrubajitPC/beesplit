class StoreController < ApplicationController
  def show
    @store = Store.find(params[:id])
    # byebug
  end
end