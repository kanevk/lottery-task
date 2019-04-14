class LotteryDrawsController < ApplicationController
  def create
    render json: { tickets: LotteryDraw.find_winning_tickets(LotteryDraw.draw_numbers) }
  end
end
