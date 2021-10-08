require './app/stores/master_of_coin'

class Purchase
  def self.call(**args)
    new(**args).call
  end

  STEPS = %w[validate_item_id set_item validate_user_balance
             pop_item create_change print_change charge_user].freeze

  def initialize(inventory:, user:, item_id:)
    @inventory = inventory
    @user = user
    @item_id = item_id
    @received_change = 0
    @coins = []
    @message = ''
  end

  def call
    success = STEPS.inject(true) { |result, step| result && send(step) }
    OpenStruct.new(success: success, message: message)
  end

  private

  attr_accessor :inventory, :user, :item_id, :item, :message, :received_change, :coins

  def validate_item_id
    if item_id.zero?
      @message = '! Your input is invalid'
      return false
    elsif !inventory.available?(id: item_id)
      @message = '! Item out of stock / does not exist'
      return false
    end

    true
  end

  def set_item
    @item = inventory.find_by_id(id: item_id)
  end

  def validate_user_balance
    if user.balance.zero?
      @message = '! Arggh! Those are not coins or you balance is 0!'
      return false
    end

    return true if user.enough_funds?(amount: item.price)

    @message = "! Arggh! #{user.humanized_balance} is not enough to buy #{item.name}"
    false
  end

  def pop_item
    inventory.pop(id: item_id)
    @message = 'Yay! Purchase successfull!'

    true
  end

  def create_change
    expected_change = user.balance - item.price
    return true if expected_change.zero?

    @received_change, @coins = MasterOfCoin.instance.give_change(expected_change)
    true
  end

  def print_change
    if coins&.any?
      preety_coins = coins.to_s.gsub(/[{|}]/, '').gsub('=>', '$ x ')
      @message += "\nHere is your change I could find: #{preety_coins},"\
                  " in total: #{@received_change / 100.to_f}$"
    else
      @message += "\nSorry man. No coins left for change :("
    end

    true
  end

  # We should reduce from user balance the price of an item + all the change we gave
  # so in case we didn't give enough change user can purchase other items
  def charge_user
    user.charge!(amount: item.price + received_change)

    true
  end
end
