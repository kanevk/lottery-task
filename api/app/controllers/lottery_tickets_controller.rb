class LotteryTicketsController < ApplicationController
  def index
    render json: { tickets_count: LotteryTicket.count }
  end

  def create
    # ticket = LotteryTicket.create_from_list(1, params[:numbers])
    ticket = LotteryTicket.create(params.require(:ticket).permit(:nickname, numbers: []).merge(lottery_id: 1))

    render json: { id: ticket.id }, status: :created
  end
end
