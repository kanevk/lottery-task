class RemoveLotteryTable < ActiveRecord::Migration[5.2]
  def change
    remove_column :lottery_tickets, :lottery_id, foreign_key: true
    drop_table :lotteries
  end
end
