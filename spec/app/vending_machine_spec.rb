# require 'vending_monster'
require 'spec_helper'
require './app/vending_machine'

RSpec.describe VendingMachine do
  context('.run') do
    it 'calls #new#call' do
      vending_monster = double('vending_monster')
      allow(described_class).to receive(:new).and_return(vending_monster)
      allow(vending_monster).to receive(:call).and_return(true)

      described_class.run

      expect(vending_monster).to have_received(:call)
    end
  end

  context('#initialize') do
    it 'initializes class and assigns inventory' do
      inventory = double('inventory')
      allow(Inventory).to receive(:instance).and_return(inventory)

      instance = described_class.new
      expect(instance.send(:inventory)).to eq(inventory)
    end
  end

  context('#call') do
    let(:instance) { described_class.new }

    let(:list) do
      [OpenStruct.new(name: 'Coca Cola', price: 200, quantity: 2),
       OpenStruct.new(name: 'Sprite', price: 250, quantity: 2)]
    end

    before do
      allow(instance).to receive(:gets).and_return("1\n", "1\n", "q\n")

      allow(Messenger).to receive(:print).and_return(true)
      allow(Messenger).to receive(:print_asset).and_return(true)
      allow(Messenger).to receive(:clear).and_return(true)
      allow(Messenger).to receive(:empty_line).and_return(true)

      inventory = double('inventory')
      allow(inventory).to receive(:list).and_return(list)
      allow(Inventory).to receive(:instance).and_return(inventory)

      allow(Purchase).to receive(:call).and_return(
        OpenStruct.new(success: true, msg: 'Sucess')
      )

      instance.call
    end

    it 'prints greeting' do
      expect(Messenger).to have_received(:print).with(
        msg: 'Hello, I\'m a Vending Moonster!'
      )
    end

    it 'lists available items' do
      expect(Messenger).to have_received(:print).with(
        msg: 'Inventory Available:'
      )
      expect(Messenger).to have_received(:print).with(
        msg: '1. Coca Cola 2.0$ - 2 left'
      )
      expect(Messenger).to have_received(:print).with(
        msg: '2. Sprite 2.5$ - 2 left'
      )
    end

    it 'prints purchase status message' do
      expect(Messenger).to have_received(:print).with(msg: 'Success')
    end
  end
end
