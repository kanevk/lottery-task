# class ArrayJsonbType < ActiveModel::Type::Value
#   def type
#     :jsonb
#   end

#   def cast(numbers)
#     numbers.map(&:to_i).sort
#   end

#   def deserialize(value)
#     value ? JSON.parse(value).sort : []
#   end

#   def serialize(value)
#     value ? value.to_json : nil
#   end
# end

class LotteryBitSerializer < ActiveModel::Type::Value
  def type
    :'BIT VARYING(50)'
  end

  def cast(numbers)
    numbers.map(&:to_i)
  end

  def deserialize(bit_string)
    return unless bit_string

    bit_string[1..-1].each_char.map.with_index { |bit, i| bit == '1' ? i + 1 : nil }.compact
  end

  def serialize(numbers)
    numbers ? numbers.each_with_object('1' + '0' * 49) { |n, binary| binary[n] = '1' } : nil
  end
end

# class LotteryNumbersValidator < ActiveModel::Validator
#   LOTTERY_NUMBERS_COUNT = 6
#   def validate(record)
#     @options[:attributes].each do |attr_name|
#       numbers = record.public_send(attr_name)
#       record.errors[attr_name] << 'are not an Array.' unless numbers.is_a?(Array)

#       if numbers.size != LOTTERY_NUMBERS_COUNT
#         record.errors[attr_name] << "are #{numbers.count} (should be #{LOTTERY_NUMBERS_COUNT})."
#       end

#       if numbers.uniq.size != numbers.size
#         record.errors[attr_name] << 'are not unique.'
#       end
#     end
#   end
# end

# winning the lottery. Where the Jackpot is to be divided as follows:
# 3 numbers - 10% of the Jackpot
# 4 numbers - 15% of the Jackpot
# 5 numbers - 25% of the Jackpot
# 6 numbers - 50% of the Jackpot, or all 100%, if there are no other sequences of winning tickets other than 6

class LotteryTicket < ApplicationRecord
  WinningTicket = Struct.new :nickname, :numbers, :matches_count, :prize, keyword_init: true
  # attribute :numbers, ArrayJsonbType.new
  attribute :bit_serialized_numbers, LotteryBitSerializer.new
  alias_attribute :numbers, :bit_serialized_numbers

  def self.find_matching_numbers(winning_numbers)
    jackpot = Lottery::JACKPOT
    tickets_by_match_count =
      [3, 4, 5, 6].reduce({}) do |hash, matches_count|
        hash.merge(
          matches_count => where(<<-SQL, winning_bits: LotteryBitSerializer.new.serialize(winning_numbers), matches_count: matches_count + 2).to_a
            array_length(regexp_split_to_array((bit_serialized_numbers & B:winning_bits)::text, E'0*'), 1) = :matches_count
          SQL
        )
      end

    if tickets_by_match_count[3].empty? && tickets_by_match_count[4] && tickets_by_match_count[5]
      winning_tickets_count = tickets_by_match_count[6].count
      tickets_by_match_count[6].map do |ticket|
        WinningTicket.new(nickname: ticket.nickname, numbers: ticket.numbers, matches_count: 6, prize: (jackpot / winning_tickets_count).round(2))
      end
    else
      tickets_by_match_count.flat_map do |matches_count, tickets|
        local_jackpot = Lottery::JACKPLOT_PER_MATCHES.fetch(matches_count)

        tickets.map do |ticket|
          WinningTicket.new(nickname: ticket.nickname, numbers: ticket.numbers, matches_count: matches_count, prize: (local_jackpot / tickets.count).round(2))
        end
      end
    end
  end
end
