class LotteryTicket < ApplicationRecord
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

  attribute :bit_serialized_numbers, LotteryBitSerializer.new
  alias_attribute :numbers, :bit_serialized_numbers

  def self.matches_for(winning_numbers, match_threshold)
    query_interpolation = {
      winning_bits: LotteryBitSerializer.new.serialize(winning_numbers),
      # We add 1 here since the bit representation always start with additional '1' in order to be valid
      matches_count: match_threshold + 1
    }

    where(<<-SQL, query_interpolation).to_a
      char_length(replace((bit_serialized_numbers & B:winning_bits)::text, '0', '')) = :matches_count
    SQL
  end
end
