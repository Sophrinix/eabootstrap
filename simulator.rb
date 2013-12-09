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
load 'position.rb'

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

  # Executes an orders responding whether it was accepted (i.e. a new position
  # was placed) or an error occurred.
  # The order type can be "long" or "sell".
  # The slippage is measured in pips, so it must be an integer.
  def send_order(instrument, order_type, lots, options = {})
    # Get optional parameters.
    opt = {
      :price => 0,
      :slippage => 0,
      :stop_loss => 0, 
      :take_profit => 0
    }.merge(options)

    # If price is not set, market price is assumed.
    if opt[:price] == 0 then
      opt[:price] = (order_type == "long") ? instrument.ask : instrument.bid
    end

    # Check lots.
    return false unless (lots.is_a? Float) && lots > 0
    lots = lots.round(2)

    # Check stop loss and take profit levels.
    return false unless (opt[:stop_loss] >= 0 && opt[:stop_loss] < opt[:price])
    return false unless (opt[:take_profit] == 0 || opt[:take_profit] > opt[:price])

    # Check slippage.
    return false unless opt[:slippage].kind_of? Integer

    # Executes order.
    if order_type == "long"
      # Place order.
      if (opt[:price] - instrument.ask).abs <= opt[:slippage] * instrument.pip_size
        position = Position.new(instrument,
                                order_type,
                                lots,
                                opt[:price],
                                opt[:stop_loss],
                                opt[:take_profit])
        @account.positions.push(position)

        # Margin: multiply the margin requirement by base/account quote.
        margin_ammount = lots * instrument.standard_lot / [account.leverage, instrument.leverage].min
        margin_ammount = (margin_ammount * instrument.bid).round(2)
        return false if @account.margin + margin_ammount >= @account.equity
        @account.margin = @account.margin + margin_ammount
      end
    else
       # Place order.
      if (opt[:price] - instrument.bid).abs <= opt[:slippage] * instrument.pip_size
        position = Position.new(instrument,
                                order_type,
                                lots,
                                opt[:price],
                                opt[:stop_loss],
                                opt[:take_profit])
        @account.positions.push(position)

        # Margin: multiply the margin requirement by base/account quote.
        margin_ammount = lots * instrument.standard_lot / [account.leverage, instrument.leverage].min
        margin_ammount = (margin_ammount * instrument.bid).round(2)
        return false if @account.margin + margin_ammount >= @account.equity
        @account.margin = @account.margin + margin_ammount
      end
    end

    # The order was not placed due to market conditions.
    false
  end
 
  # Schedule an order for future execution.
  def schedule_order(order)
    # No scheduled orders yet.
  end

  def execute_scheduled_orders
    # No scheduled orders yet.
  end

  # Try changing atomically the position's attributes (e.g. S/L and T/P).
  # Returns true iff changes took place.
  def change_position(position, options = {})
    # Get optional parameters.
    opt = {
      stop_loss   => position.stop_loss,
      take_profit => position.take_profit
    }.merge(options)

    # Check whether changes can be made and, if negative, returns false.
    # Bid / ask case.
    if position.order_type == "long"
      return false if
        (position.instrument.open_price - position.instrument.bid).abs <=
          position.instrument.freeze_level * position.instrument.pip_size
    else
      return false if
        (position.instrument.open_price - position.instrument.ask).abs <=
          position.instrument.freeze_level * position.instrument.pip_size
    end
    # Stop loss case.
    if position.order_type == "long"
      return false if
        (position.stop_loss - position.instrument.bid).abs <=
        position.instrument.freeze_level * position.instrument.pip_size
    else
      return false if
        (position.stop_loss - position.instrument.ask).abs <=
        position.instrument.freeze_level * position.instrument.pip_size
    end
    # Take profit case.
    if position.order_type == "long"
      return false if
        (position.take_profit - position.instrument.bid).abs <=
        position.instrument.freeze_level * position.instrument.pip_size
    else
      return false if
        (position.take_profit - position.instrument.ask).abs <=
        position.instrument.freeze_level * position.instrument.pip_size
    end

    # Set new stop loss.
    position.stop_loss = opt[:stop_loss]

    # Set new take profit.
    position.take_profit = opt[:take_profit]
    
    true
  end

  # Close an open position.
  def close_position(position)
    @account.positions.delete_at @account.positions.index(position)
  end

  #---------------------------------------------------------------------------
  # Instruments handling.
  #---------------------------------------------------------------------------

  # Register an instrument to watch / simulate / trade.
  def use_instrument(instrument)
    instruments.push(instrument)
  end

  # Advance one cursor at a time, for the correct series, according to the
  # earliest quote coming.
  # NOTE: It is assumed instruments array contains at least one instrument.
  def advance_next_cursor
    if instruments.length == 1
      instruments.first.advance_cursor
    else
      # FIXME: choose the correct cursor to advance.
      instruments.first.advance_cursor
    end
  end
  
  # Checks whether tick part of begin-tick-loop has reached its end.
  def reached_end?
    instruments.each { |instr| return false unless instr.reached_end? }
    true
  end

  #---------------------------------------------------------------------------
  # Account settings.
  #---------------------------------------------------------------------------

  # Recalculate...
  def refresh_account
    # TODO
  end

  # Returns current balance.
  def balance
    account_settings.balance
  end
  
  # Returns current equity.
  def equity
    account_settings.equity
  end
  
  # Returns current used margin.
  def margin
    account_settings.margin
  end
  
  # Returns current free margin. Actually, it is the difference from equity
  # and used margin.
  def free_margin
    account_settings.free_margin
  end
end
