require 'singleton'

COIN_CONFIG_PATH = './config/coins.yaml'.freeze

class MasterOfCoin
  include Singleton

  attr_accessor :coins

  def initialize
    json_items = YAML.load_file(COIN_CONFIG_PATH).to_json
    @coins = JSON.parse(json_items, object_class: OpenStruct)
    @coins.sort_by! { |coin| -coin.value }
  end

  def give_change(amount)
    change = []

    loop do
      coin = find_coin(amount)

      break unless coin

      coin.quantity -= 1
      change.push(coin.value)
      amount -= coin.value
    end

    change.group_by(&:itself).map { |key, values| [key / 100.to_f, values.length] }.to_h
  end

  private

  def find_coin(amount)
    coins.find { |coin| coin.value <= amount && !coin.quantity.zero? }
  end
end
