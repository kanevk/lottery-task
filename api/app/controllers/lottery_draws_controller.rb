class LotteryDrawsController < ApplicationController
  def create
    winning_numbers = Array.new(6) { SecureRandom.random_number(49) + 1 }
    Lottery.find(1).update!(winning_numbers: winning_numbers)

    winning_tickets = LotteryTicket.find_matching_numbers(winning_numbers)

    render json: { tickets: winning_tickets }
  end
end
