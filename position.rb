# SYNOPSIS
#   Holds all the information about a position, i.e. a filled order.
#   
#   Such informations are which instrument, direction (order type),
#   open price, and stop loss / take profit levels.
#
# First release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

class Position
  attr_accessor :instrument
  attr_accessor :order_type
  attr_accessor :lots
  attr_accessor :open_price
  attr_accessor :stop_loss
  attr_accessor :take_profit

  def initialize(instr, type, lot_qty, price, sl, tp)
    @instrument  = instr
    @order_type  = type
    @lots        = lot_qty
    @open_price  = price
    @stop_loss   = sl
    @take_profit = tp
  end
end
