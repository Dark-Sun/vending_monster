require 'spec_helper'
require 'json'
require './app/stores/master_of_coin'

RSpec.describe MasterOfCoin do
  let(:coins) do
    [OpenStruct.new(value: 10, quantity: 5),
     OpenStruct.new(value: 5, quantity: 10)]
  end

  let(:config_file) { double('file') }

  let(:instance) { described_class.instance }

  before do
    allow(YAML).to receive(:load_file).and_return(config_file)
    allow(config_file).to receive(:to_json).and_return(config_file)
    allow(JSON).to receive(:parse).and_return(coins)
  end

  before(:each) do
    Singleton.__init__(MasterOfCoin)
    described_class.instance
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
      it 'returns empty data' do
        expect(instance.give_change(1)).to eq([0, {}])
      end
    end

    context('no coins available') do
      let(:coins) { [] }

      it 'returns empty data' do
        expect(instance.give_change(10_000)).to eq([0, {}])
      end
    end

    context('there are enough coins for change') do
      it 'returns array with coins' do
        expect(instance.give_change(90)).to eq([90, { 0.1 => 5, 0.05 => 8 }])
      end

      it 'reduces coins quantity' do
        instance.give_change(90)

        expect(instance.instance_variable_get(:@coins)[0].quantity).to eq(0)
        expect(instance.instance_variable_get(:@coins)[1].quantity).to eq(2)
      end
    end

    context('there are not enogh coins for change') do
      it 'returns all the coins' do
        expect(instance.give_change(2000)).to eq([100, { 0.1 => 5, 0.05 => 10 }])
      end

      it 'reduces coins quantity' do
        expect(instance.give_change(2000)).to eq([100, { 0.1 => 5, 0.05 => 10 }])
        expect(instance.instance_variable_get(:@coins)[0].quantity).to eq(0)
        expect(instance.instance_variable_get(:@coins)[1].quantity).to eq(0)
      end
    end
  end
end
