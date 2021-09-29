require 'spec_helper'
require './app/stores/master_of_coin'

RSpec.describe MasterOfCoin do
  let(:coins) do
    [OpenStruct.new(value: 10, quantity: 5),
     OpenStruct.new(quantity: 5, quantity: 10)]
  end

  let(:instance) { described_class.instance }

  before do
    allow(YAML).to receive(:load_file).and_return(config_file)
    allow(config_file).to receive(:to_json).and_return(config_file)
    allow(JSON).to receive(:parse).and_return(coins)
  end

  describe('#initialize') do
    it 'sets initial coins from config' do
      expect(instance.instance_variable_get(:@coins)).to eq(coins)
    end
  end

  describe('#instance') do
    it 'behaves like a singleton' do
      expect(described_class.instance).to eq(
        described_class.instance
      )
    end
  end

  describe('#give_change') do
    context('amount is less than minimum coin') do
      it 'returns empty array' do
        expect(instance.give_change(1)).to eq([])
      end
    end

    context('no coins available') do
      let(:coins) { [] }

      it 'returns empty array' do
        expect(instance.give_change(10_000)).to eq([])
      end
    end

    context('there are enough coins for change') do
      it 'returns array with coins' do
        expect(instance.give_change(90)).to eq([10 => 5, 5 => 8])
      end

      it 'reduces coins quantity' do
        expect(instance.give_change(90))
        expect(instance.instance_variable_get(:@coins).first.quantity).to eq(0)
        expect(instance.instance_variable_get(:@coins).second.quantity).to eq(2)
      end
    end

    context('there are not enogh coins for change') do
      it 'returns all the coins' do
        expect(instance.give_change(2000)).to eq([10 => 5, 5 => 10])
      end

      it 'reduces coins quantity' do
        expect(instance.give_change(2000)).to eq([10 => 5, 5 => 10])
        expect(instance.instance_variable_get(:@coins).first.quantity).to eq(0)
        expect(instance.instance_variable_get(:@coins).second.quantity).to eq(0)
      end
    end
  end
end
