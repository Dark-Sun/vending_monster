require 'spec_helper'
require './app/stores/inventory'
require './app/stores/user'
require './app/services/purchase'

RSpec.describe Purchase do
  context('.call') do
    it 'calls #new #call' do
      purchase = double('purchase')
      allow(described_class).to receive(:new).and_return(purchase)
      allow(purchase).to receive(:call).and_return(true)

      described_class.call(
        inventory: 'inventory',
        user: User.new(balance: 10_000),
        item_id: 'item_id'
      )

      expect(purchase).to have_received(:call)
    end
  end

  let(:master_of_coin) { double('master_of_coin') }

  let(:options) do
    {
      inventory: Inventory.instance,
      user: User.new(balance: 10_000),
      item_id: 1
    }
  end

  before do
    allow(MasterOfCoin).to receive(:instance).and_return(master_of_coin)
    allow(master_of_coin).to receive(:give_change).and_return([1000, { 500 => 2 }])
  end

  before(:each) do
    Singleton.__init__(Inventory)
  end

  describe('#call') do
    context('with invalid item id') do
      it 'fails with error message' do
        options[:item_id] = 0
        result = described_class.new(**options).call

        expect(result.success).to eq(false)
        expect(result.message).to eq('! Your input is invalid')
      end
    end

    context('with item out of stock') do
      it 'fails with error message' do
        options[:item_id] = 5
        result = described_class.new(**options).call

        expect(result.success).to eq(false)
        expect(result.message).to eq('! Item out of stock / does not exist')
      end
    end

    context('with invalid user balance') do
      it 'fails with error message' do
        options[:user] = User.new(balance: 0)
        result = described_class.new(**options).call

        expect(result.success).to eq(false)
        expect(result.message).to eq('! Arggh! Those are not coins or you balance is 0!')
      end
    end

    context('with user balance not enough for purchase') do
      it 'fails with error message' do
        options[:user] = User.new(balance: 100)
        result = described_class.new(**options).call

        expect(result.success).to eq(false)
        expect(result.message).to eq('! Arggh! 1.0$ is not enough to buy Coca Cola')
      end
    end

    context('with valid item and user balance') do
      it 'succeds with message' do
        result = described_class.new(**options).call

        expect(result.success).to eq(true)
        expect(result.message).to match('Yay! Purchase successfull!')
      end
    end

    context('no coins for change available') do
      it 'sets error message' do
        allow(master_of_coin).to receive(:give_change).and_return([0, {}])
        result = described_class.new(**options).call

        expect(result.message).to include('Sorry man. No coins left for change')
      end
    end

    context('coins for change are available') do
      it 'returns message with change' do
        result = described_class.new(**options).call

        expect(result.message).to include(
          'Here is your change I could find: 500$ x 2, in total: 10.0$'
        )
      end
    end
  end
end
