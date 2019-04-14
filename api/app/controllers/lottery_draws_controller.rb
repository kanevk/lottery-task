class LotteryDrawsController < ApplicationController
  def create
    render json: { tickets: LotteryDraw.call }
  end
end
