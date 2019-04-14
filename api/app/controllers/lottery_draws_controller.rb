class LotteryDrawsController < ApplicationController
  def create
    lottery = Lottery.find(1)
    lottery.update!(winning_numbers: Lottery.draw)

    winning_tickets = LotteryTicket.find_matching_numbers(lottery.winning_numbers)

    render json: { tickets: winning_tickets }
  end
end
