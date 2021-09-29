require 'spec_helper'
require './app/stores/inventory'

RSpec.describe Inventory do
  let(:inventory) do
    [OpenStruct.new(name: 'Coca Cola', price: 200, quantity: 2),
     OpenStruct.new(name: 'Sprite', price: 250, quantity: 0)]
  end

  let(:config_file) { double('file') }

  let!(:instance) { described_class.instance }

  before do
    allow(YAML).to receive(:load_file).and_return(config_file)
    allow(config_file).to receive(:to_json).and_return(config_file)
    allow(JSON).to receive(:parse).and_return(inventory)
  end

  before(:each) do
    Singleton.__init__(Inventory)
    described_class.instance
  end

  describe('#instance') do
    it 'behaves like a singleton' do
      expect(described_class.instance).to eq(
        described_class.instance
      )
    end
  end

  describe('#new') do
    it 'raises an error' do
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end

  describe('#initialize') do
    it 'reads config file' do
      expect(YAML).to have_received(:load_file)
    end

    it 'sets @items variable' do
      expect(instance.instance_variable_get(:@items)).to be_a(Array)
    end

    it 'issigns ids to items' do
      expect(instance.instance_variable_get(:@items).first.id).to eq(1)
    end
  end

  describe('#list') do
    it 'returns list of items' do
      list = instance.list
      expect(list).to be_a(Array)
      expect(list.first).to be_a(OpenStruct)
      expect(list.first.name).to eq('Coca Cola')
    end
  end

  describe('#find_by_id') do
    context('item exists') do
      it 'returns an item' do
        item = instance.find_by_id(id: 1)
        expect(item.name).to eq('Coca Cola')
        expect(item.price).to eq(200)
      end
    end

    context('#item does not exist') do
      it 'returns nil' do
        expect(instance.find_by_id(id: 99)).to eq(nil)
      end
    end
  end

  describe('#pop') do
    context('item is in stock') do
      it 'reduces item quantity by 1' do
        instance.pop(id: 1)
        item = instance.find_by_id(id: 1)
        expect(item.quantity).to eq(1)
      end

      it 'returns true' do
        expect(instance.pop(id: 1)).to eq(true)
      end
    end

    context('item does not exists') do
      it 'raises an error' do
        expect { instance.pop(id: 2) }.to raise_error('No items left')
      end
    end

    context('item out of stock') do
      it 'raises an error' do
        expect { instance.pop(id: 2) }.to raise_error('No items left')
      end
    end
  end

  describe('#available?') do
    context('item exists and in stock') do
      it 'returns true' do
        result = instance.available?(id: 1)
        expect(result).to eq(true)
      end
    end

    context('item exists but out of stock') do
      it 'returns false' do
        result = instance.available?(id: 2)
        expect(result).to eq(false)
      end
    end

    context('item does not exist') do
      it 'returns false' do
        result = instance.available?(id: 99)
        expect(result).to eq(false)
      end
    end
  end
end
