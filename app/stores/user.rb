class User
  attr_accessor :balance

  def initialize(balance:)
    @balance = balance
  end

  def humanized_balance
    "#{balance / 100.to_f}$"
  end

  def charge!(amount:)
    @balance -= amount
  end

  def enough_funds?(amount:)
    @balance >= amount
  end
end
