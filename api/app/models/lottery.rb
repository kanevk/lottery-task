class Lottery < ApplicationRecord
  JACKPOT = 1_000_000.to_d

  JACKPLOT_PER_MATCHES = {
    3 => 0.10 * JACKPOT,
    4 => 0.15 * JACKPOT,
    5 => 0.25 * JACKPOT,
    6 => 0.50 * JACKPOT
  }.freeze

  def self.draw
    (1..49).to_a.sample(6)
  end
end
