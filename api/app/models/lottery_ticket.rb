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

class LotteryTicket < ApplicationRecord
  # attribute :numbers, ArrayJsonbType.new
  attribute :bit_serialized_numbers, LotteryBitSerializer.new

  # validates :numbers, lottery_numbers: true

  # def self.number_subsets(winning_numbers, n)
  #   where('array_length(ARRAY(select jsonb_array_elements(numbers) INTERSECT select jsonb_array_elements(?::jsonb)), 1) = ?', winning_numbers.to_json, n)
  # end

  def self.bit_number_subsets(winning_numbers, n)
    serialized_winning_numbers = LotteryBitSerializer.new.serialize(winning_numbers)
    where("array_length(regexp_split_to_array((bit_serialized_numbers & B:winning_bits)::text, E'0*'), 1) = :occurences", winning_bits: serialized_winning_numbers, occurences: n + 2)
  end

  def self.find_matching_numbers(winning_numbers)
    find_matching_numbers_ruby(winning_numbers)
  end

  # def self.find_matching_numbers_sql(winning_numbers)
  #   [3, 4, 5, 6].flat_map do |set_size|
  #     number_subsets(winning_numbers, set_size)
  #       .map { |ticket| { matches_count: set_size, prize: 300, numbers: ticket.numbers } }
  #   end
  # end

  def self.find_matching_numbers_bit_sql(winning_numbers)
    [3, 4, 5, 6].flat_map do |set_size|
      bit_number_subsets(winning_numbers, set_size)
        .map { |ticket| { matches_count: set_size, prize: 300, numbers: ticket.bit_serialized_numbers } }
    end
  end

  def self.find_matching_numbers_ruby(winning_numbers)
    winning_set = winning_numbers.to_set
    matches = []
    find_each(batch_size: 100_000) do |ticket|
      matches_count = ticket.bit_serialized_numbers.select { |n| winning_set.include?(n) }.count
      matches << { matches_count: matches_count, numbers: ticket.numbers } if matches_count >= 3
    end
    matches
  end
end
