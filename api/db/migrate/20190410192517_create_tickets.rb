class CreateTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :lotteries do |t|
      t.datetime :drawn_on
      t.jsonb :winning_numbers
    end

    create_table :lottery_tickets do |t|
      t.string :nickname, null: false
      t.belongs_to :lottery, null: false, foreign_key: true
      t.jsonb :numbers, null: false
    end
  end
end
