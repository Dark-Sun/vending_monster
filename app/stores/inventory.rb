require 'yaml'
require 'json'
require 'singleton'

INVENTORY_CONFIG_PATH = './config/inventory.yaml'.freeze

class Inventory
  include Singleton

  def initialize
    load_items
    assign_ids
  end

  def list
    @items
  end

  def find_by_id(id:)
    @items.find { |el| el.id == id }
  end

  def pop(id:)
    item = find_by_id(id: id)

    raise 'No items left' unless item.quantity.positive?

    item.quantity -= 1
    true
  end

  def available?(id:)
    item = find_by_id(id: id)
    !!item&.quantity&.positive?
  end

  private

  def load_items
    json_items = YAML.load_file(INVENTORY_CONFIG_PATH).to_json
    @items = JSON.parse(json_items, object_class: OpenStruct)
  end

  def assign_ids
    @items.map.with_index { |item, index| item.id = index + 1 }
  end
end
