class BeesController < ApplicationController

  def index

  end

  def show
    @bee = Bee.find(params[:id])
  end
end