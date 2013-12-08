# SYNOPSIS
#   Simulator executes the orders and interfaces trader's account with Expert
#   Advisor or Event Profiler.
#
#   The ideia is to capture Expert Advisor / Event Profiler's actions and
#   act as the broker, holding instruments available for trading, providing
#   an API for trading (order execution and scheduling), and access to
#   trader's account.
#
# Initial release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

load 'account.rb'
load 'position_sizing.rb'

class Simulator
public
  # Environment.
  attr_accessor :instruments          # Instruments available for trading.
  #attr_reader :simulation_method     # Simulation methods subsets dataset.
  #attr_reader :simulation_start,     # Timeframe (start and end) and period.
  #            :simulation_end,
  #            :period

  # Account object.
  attr_accessor :account              # Account information.

  # Position sizing module.
  attr_accessor :position_sizing      # Position sizing module.

  # Current ticket.
  attr_accessor :ticket               # Holds current issue ticket number.

  # Constructor.
  def initialize(balance, leverage, base_currency)
    @account = Account.new(balance, balance, 0, leverage, base_currency)
    @instruments = []
    @ticket = 0
   end
  
  #---------------------------------------------------------------------------
  # Interaction with the server.
  #---------------------------------------------------------------------------
  def send_order(order)
  end

  def schedule_order(order)
  end
  
  def execute_instant_orders
  end

  def execute_scheduled_orders
  end

  def place_position(order)
  end

  #---------------------------------------------------------------------------
  # Instruments handling.
  #---------------------------------------------------------------------------
  def use_instrument(instrument)
    instruments.push(instrument)
  end

  def advance_cursors
    instruments.first.advance_cursor
  end

  def reached_end?
    instruments.length == 0 || instruments.first.reached_end?
  end

  #---------------------------------------------------------------------------
  # Account settings.
  #---------------------------------------------------------------------------
  def refresh_account
  end

  def balance
    account_settings.balance
  end
  
  def equity
    account_settings.equity
  end

  def margin
    account_settings.margin
  end

  def free_margin
    account_settings.free_margin
  end
end
