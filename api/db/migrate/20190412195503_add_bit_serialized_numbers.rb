require 'activerecord-import/base'
# load the appropriate database adapter (postgresql, mysql2, sqlite3, etc)
require 'activerecord-import/active_record/adapters/postgresql_adapter'

class AddBitSerializedNumbers < ActiveRecord::Migration[5.2]
  def change
    add_column :lottery_tickets, :bit_serialized_numbers, :'BIT VARYING(50)'
    change_column :lottery_tickets, :numbers, :jsonb, null: true

    updates =
      LotteryTicket.pluck(:id, :numbers).each_with_object([]) do |(id, numbers), arr|
        arr << { id: id, bit_serialized_numbers: serialize_numbers(numbers) }
      end

    LotteryTicket.import updates, on_duplicate_key_update: [:bit_serialized_numbers]
  end

  def serialize_numbers(numbers)
    numbers.each_with_object('1' + '0' * 49) { |n, binary| binary[n] = '1' }
  end
end
