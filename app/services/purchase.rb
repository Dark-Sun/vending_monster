require './app/stores/master_of_coin'

class Purchase
  def self.call(**args)
    new(**args).call
  end

  def initialize(inventory:, user_balance:, item_id:)
    @inventory = inventory
    @user_balance = user_balance
    @item_id = item_id
    @change = 0
    @message = ''
  end

  def call
    success = validate_item &&
              set_item &&
              validate_user_balance &&
              purchase &&
              give_change

    OpenStruct.new(success: success, message: message)
  end

  private

  attr_accessor :inventory, :user_balance, :item_id, :item, :message, :change

  def validate_item
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
    if user_balance.zero?
      @message = '! Arggh! Those are not coins! Insert valid coins!'
      return false
    end

    return true if user_balance >= item.price

    @message = "! Arggh! #{user_balance / 100.to_f}$ is not enough to buy #{item.name}"
    false
  end

  def purchase
    @change = user_balance - item.price
    inventory.pop(id: item_id)
    @message = "Yay! Purchase successfull! Your change is #{change / 100.to_f}$"

    true
  end

  def give_change
    return true if change.zero?

    coins = MasterOfCoin.instance.give_change(change)

    if coins.any?
      preety_coins = coins.to_s.gsub(/[{|}]/, '').gsub('=>', '$ x ')
      @message += "\nHere are the coins I could find: #{preety_coins}"
    else
      @message += "\nSorry man. No coins left for change :("
    end

    true
  end
end
