module LotteryDraw
  module_function

  WinningTicket = Struct.new :nickname, :numbers, :matches_count, :prize, keyword_init: true

  JACKPOT = 1_000_000.to_d

  JACKPLOT_PER_MATCHES = {
    3 => 0.10 * JACKPOT,
    4 => 0.15 * JACKPOT,
    5 => 0.25 * JACKPOT,
    6 => 0.50 * JACKPOT
  }.freeze

  def call
    winning_numbers = (1..49).to_a.sample(6, random: SecureRandom)

    find_matching_numbers(winning_numbers)
  end

  def find_matching_numbers(winning_numbers)
    tickets_by_match_count =
      [3, 4, 5, 6].reduce({}) do |hash, matches_count|
        hash.merge(matches_count => LotteryTicket.matches_for(winning_numbers, matches_count))
      end

    if tickets_by_match_count[3].empty? && tickets_by_match_count[4] && tickets_by_match_count[5]
      winning_tickets_count = tickets_by_match_count[6].count
      tickets_by_match_count[6].map do |ticket|
        WinningTicket.new(nickname: ticket.nickname, numbers: ticket.numbers, matches_count: 6, prize: (JACKPOT / winning_tickets_count).round(2))
      end
    else
      tickets_by_match_count.flat_map do |matches_count, tickets|
        local_jackpot = JACKPLOT_PER_MATCHES.fetch(matches_count)

        tickets.map do |ticket|
          WinningTicket.new(nickname: ticket.nickname, numbers: ticket.numbers, matches_count: matches_count, prize: (local_jackpot / tickets.count).round(2))
        end
      end
    end
  end
end
