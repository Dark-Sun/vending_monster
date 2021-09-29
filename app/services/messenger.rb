class Messenger
  def self.print(msg:)
    puts msg
  end

  def self.print_asset(name:)
    content = File.read("./assets/#{name}")
    Messenger.print(msg: content)
  end

  def self.empty_line
    puts ''
  end

  def self.clear
    # system('clr') # Uncomment for Windows
    system('clear')
  end
end
