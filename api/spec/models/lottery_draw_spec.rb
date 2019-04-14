require 'rails_helper'

describe LotteryDraw do
  describe '.find_winning_tickets' do
    context 'having only tickets with 6 matches' do
      it 'gives the whole Jackpot when the winning ticket is one' do
        create_ticket(numbers: [1, 2, 3, 4, 5, 6])

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 6], prize: LotteryDraw::JACKPOT)
        )
      end

      it 'splits the Jackpot when there are multiple winning tickets' do
        create_ticket(numbers: [1, 2, 3, 4, 5, 6])
        create_ticket(numbers: [1, 2, 3, 4, 5, 6])

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 6], prize: LotteryDraw::JACKPOT / 2),
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 6], prize: LotteryDraw::JACKPOT / 2)
        )
      end

      it 'marks the winning ticket as a winner' do
        create_ticket(numbers: [1, 2, 3, 4, 5, 6])

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 6], winner: true)
        )
      end
    end

    context 'having tickets less varies matches' do
      it 'gives only half of the Jackpot to the winner' do
        create_ticket(numbers: [1, 2, 3, 41, 42, 43])
        create_ticket(numbers: [1, 2, 3, 4, 5, 6])

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 6], prize: LotteryDraw::JACKPOT / 2),
          an_object_having_attributes(numbers: [1, 2, 3, 41, 42, 43])
        )
      end

      it 'splits the partial pot between the tickets with 3 matches' do
        create_ticket(numbers: [1, 2, 3, 41, 42, 43])
        create_ticket(numbers: [1, 2, 3, 41, 42, 43])

        partial_pot = 0.10 * LotteryDraw::JACKPOT

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 41, 42, 43], prize: partial_pot / 2),
          an_object_having_attributes(numbers: [1, 2, 3, 41, 42, 43], prize: partial_pot / 2)
        )
      end

      it 'splits the partial pot between the tickets with 4 matches' do
        create_ticket(numbers: [1, 2, 3, 4, 42, 43])
        create_ticket(numbers: [1, 2, 3, 4, 42, 43])

        partial_pot = 0.15 * LotteryDraw::JACKPOT

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 42, 43], prize: partial_pot / 2),
          an_object_having_attributes(numbers: [1, 2, 3, 4, 42, 43], prize: partial_pot / 2)
        )
      end

      it 'splits the partial pot between the tickets with 5 matches' do
        create_ticket(numbers: [1, 2, 3, 4, 5, 43])
        create_ticket(numbers: [1, 2, 3, 4, 5, 43])

        partial_pot = 0.25 * LotteryDraw::JACKPOT

        winning_tickets = LotteryDraw.find_winning_tickets([1, 2, 3, 4, 5, 6])

        expect(winning_tickets).to contain_exactly(
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 43], prize: partial_pot / 2),
          an_object_having_attributes(numbers: [1, 2, 3, 4, 5, 43], prize: partial_pot / 2)
        )
      end
    end
  end

  def create_ticket(**attributes)
    LotteryTicket.create!(attributes.merge(nickname: 'nickname'))
  end
end
