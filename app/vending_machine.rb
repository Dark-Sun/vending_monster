require './app/stores/inventory'
require './app/services/messenger'
require './app/services/purchase'

USER_BALANCE_REGEXP = /[0-9]*[.]{0,1}[0-9]{0,2}/

class VendingMachine
  def self.run
    new.call
  end

  def initialize
    @inventory = Inventory.instance
  end

  def call
    Messenger.clear
    print_greeting

    loop do
      list_items
      purchase(promt_item_id, promt_user_balance)
    end
  end

  private

  attr_accessor :inventory

  def print_greeting
    Messenger.print_asset(name: 'machine')
    Messenger.empty_line
    Messenger.print(msg: 'Hello, I\'m a Vending Moonster!')
    Messenger.empty_line
  end

  def list_items
    Messenger.empty_line
    Messenger.empty_line
    Messenger.print(msg: '------------------------')
    Messenger.print(msg: 'Inventory Available:')

    inventory.list.each do |item|
      Messenger.print(
        msg: "#{item.id}. #{item.name} "\
             "#{item.price / 100.to_f}$ - #{item.quantity} left"
      )
    end
  end

  def promt_item_id
    Messenger.empty_line
    Messenger.print(msg: 'Type me an item number you want / type q to exit: ')
    Messenger.empty_line
    input = gets.chomp
    exit if input == 'q'
    input.to_i
  end

  def promt_user_balance
    Messenger.empty_line
    Messenger.print(msg: 'Enter your inseted amount of coins (in $):')
    Messenger.empty_line

    input = gets.chomp.match(USER_BALANCE_REGEXP)[0]
    input = format('%.2f', input).to_f
    (input * 100).to_i
  end

  def purchase(item_id, user_balance)
    Messenger.clear
    result = Purchase.call(
      inventory: inventory,
      user_balance: user_balance,
      item_id: item_id
    )

    Messenger.print_asset(name: 'bottle') if result.success
    Messenger.print(msg: result.message)
  end
end
