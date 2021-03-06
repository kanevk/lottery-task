# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'activerecord-import/base'
# load the appropriate database adapter (postgresql, mysql2, sqlite3, etc)
require 'activerecord-import/active_record/adapters/postgresql_adapter'

tickets_count = (ENV['LOTTERY_TICKETS_COUNT'] || 10_000).to_i

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.transaction do
  numbers_basket = (1..49).to_a

  puts 'Constructing imports'
  tickets_data =
    Array.new(tickets_count) do |i|
      {
        nickname: "bill-#{i}",
        bit_serialized_numbers: numbers_basket.sample(6)
      }
    end

  puts 'Importing'
  LotteryTicket.import tickets_data, validate: true
end
