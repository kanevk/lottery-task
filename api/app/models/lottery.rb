class Lottery < ApplicationRecord
  def self.draw
    (1..49).to_a.sample(6)
  end
end
