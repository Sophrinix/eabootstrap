# SYNOPSIS
#   ...
# 
# Initial release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

class Order
  attr_accessor :instrument    # Reference to instrument to be traded.
  attr_accessor :order_type    # Instant, limit or stop sell/buy orders.
  attr_accessor :lot_size      # Lot size respecting minimum and step lot.
  attr_accessor :open_price    # Open price request.
  attr_accessor :slippage      # Slippage, in pips.
  attr_accessor :take_profit   # Take profit, in absolute value.
  attr_accessor :stop_loss     # Stop loss, in absolute value.
  
  # Initialize order's settings.
  def initialize(instr, ordertype, lotsize, price, slippage_in_pips = 3,
                 tp = 0, sl = 0)
    instrument  = instr
    order_type  = ordertype
    lot_size    = lotsizie
    open_price  = price
    slippage    = slippage_in_pips
    take_profit = tp
    stop_loss   = sl
  end
end

