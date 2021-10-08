require 'spec_helper'
require './app/stores/user'

RSpec.describe User do
  context('#new') do
    let(:balance) { 100 }
    let!(:user) { described_class.new(balance: balance) }

    it 'assigns balance to user' do
      expect(user.balance).to eq(balance)
    end
  end

  context('#humanized_balance') do
    let!(:user) { described_class.new(balance: 105) }

    it 'outputs balance nicely in $' do
      expect(user.humanized_balance).to eq('1.05$')
    end
  end

  context('#enough_funds?') do
    let(:balance) { 100 }
    let!(:user) { described_class.new(balance: balance) }

    context('user has enough funds') do
      it 'returns true' do
        expect(user.enough_funds?(amount: balance)).to eq(true)
        expect(user.enough_funds?(amount: balance - 0.1)).to eq(true)
      end
    end

    context('user does not have enough funds') do
      it 'returns false' do
        expect(user.enough_funds?(amount: balance + 0.1)).to eq(false)
      end
    end
  end

  context('#charge!') do
    let!(:user) { described_class.new(balance: 100) }

    it 'reduces user balance by charged amount' do
      user.charge!(amount: 40)

      expect(user.balance).to eq(60)
    end
  end
end
