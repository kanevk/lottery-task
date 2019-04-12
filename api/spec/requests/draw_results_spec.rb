require 'rails_helper'

describe 'Lottery draws' do
  describe 'POST create' do
    it '' do
      allow(Lottery).to receive :find
      allow(Ticket).to receive :create_from_list

      headers = { 'ACCEPT' => 'application/json' }
      post '/lotteries/1/draw_results', headers: headers

      expected_winning_tickets = [
        an_object_having_attributes(matching_numbers: 3, prize: 20),
        an_object_having_attributes(matching_numbers: 3, prize: 20),
        an_object_having_attributes(matching_numbers: 4, prize: 100),
        an_object_having_attributes(matching_numbers: 5, prize: 1_000),
        an_object_having_attributes(matching_numbers: 6, prize: 100_000)
      ]

      expect(response.content_type).to eq('application/json')
      expect(response.body).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq hash_including(winning_tickets: expected_winning_tickets)
    end
  end
end
