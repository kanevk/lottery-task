require 'rails_helper'

describe LotteryTicket do
  describe '.matches_for' do
    it 'finds tickets with N matching numbers' do
      create_ticket numbers: [40, 41, 42, 43, 44, 45]
      ticket = create_ticket numbers: [1, 2, 3, 4, 5, 6]

      matches = LotteryTicket.matches_for([1, 2, 3, 4, 5, 6], 6)
      expect(matches).to contain_exactly(ticket)
    end

    it 'finds tickets with N matching numbers ignores the ones with N+1' do
      create_ticket numbers: [1, 2, 46, 47, 48, 49]
      ticket = create_ticket numbers: [1, 2, 3, 47, 48, 49]

      matches = LotteryTicket.matches_for([44, 45, 46, 47, 48, 49], 3)
      expect(matches).to contain_exactly(ticket)
    end

    it 'finds tickets with N matching numbers ignores the ones with N - 1' do
      create_ticket numbers: [1, 2, 3, 4, 48, 49]
      ticket = create_ticket numbers: [1, 2, 3, 47, 48, 49]

      matches = LotteryTicket.matches_for([44, 45, 46, 47, 48, 49], 3)
      expect(matches).to contain_exactly(ticket)
    end
  end

  def create_ticket(**attributes)
    LotteryTicket.create!(attributes.merge(nickname: 'nickname'))
  end
end
