require 'spec_helper'
require './app/services/messenger'

RSpec.describe Messenger do
  before do
    allow(described_class).to receive(:puts).and_return(true)
  end

  describe('.print') do
    it 'passes message to #puts' do
      described_class.print(msg: 'Test')
      expect(described_class).to have_received(:puts).with('Test')
    end
  end

  describe('.print_asset') do
    it 'read file from assets folder an prints it' do
      allow(described_class).to receive(:print).and_return(true)
      allow(File).to receive(:read).and_return('test')

      described_class.print_asset(name: 'test')
      expect(described_class).to have_received(:print).with(msg: 'test')
    end
  end

  describe('.empty_line') do
    it 'prints empty line' do
      described_class.empty_line
      expect(described_class).to have_received(:puts).with('')
    end
  end

  describe('.clear') do
    it 'clears console screen' do
      allow(described_class).to receive(:system).and_return(true)
      described_class.clear
      expect(described_class).to have_received(:system).with('clear')
    end
  end
end
