require 'rails_helper'

describe LotteryTicket do
  describe '.matches_for' do
    it 'finds tickets with 6 matching numbers' do
      numbers = [1, 2, 3, 4, 5, 6]
      ticket = create_ticket numbers: numbers

      matches = LotteryTicket.matches_for([1, 2, 3, 4, 5, 6], 6)
      expect(matches).to contain_exactly(ticket)
    end

    it 'finds tickets with 3 matching numbers' do
      numbers = [1, 2, 3, 41, 42, 43]
      ticket = create_ticket numbers: numbers

      matches = LotteryTicket.matches_for([10, 11, 12, 41, 42, 43], 3)
      expect(matches).to contain_exactly(ticket)
    end
  end

  def create_ticket(**attributes)
    LotteryTicket.create(attributes.merge(nickname: 'nickname'))
  end
end
