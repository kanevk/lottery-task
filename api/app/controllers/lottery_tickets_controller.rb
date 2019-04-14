class LotteryTicketsController < ApplicationController
  def index
    render json: { tickets_count: LotteryTicket.count }
  end

  def create
    ticket = LotteryTicket.create(params.require(:ticket).permit(:nickname, numbers: []))

    render json: { id: ticket.id }, status: :created
  end
end
