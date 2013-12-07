# SYNOPSIS
#   Instrument hold the series and meta-information about them.
#   
#   Every instrument can be of one out of two types, OHLC or tick. If such
#   instrument if OHLC, then it may have OHLC timestamped series grouped
#   according to the chosen period (1-minute data, 30-minutes data, etc);
#   otherwise, it will contain thin, timestamped ticks.
#
#   A trader have its buying-power limited to a maximum allowed leveraged.
#   If maximum leverage equals X not lower than trader's account leverage,
#   then it is understood that a position size will meet the margin taken /
#   position size ratio of 1:X.
#
#   The pip size is the atomic part of the currency and hence the very least
#   minor motion occurs lower-bounded by pip size. For instance, take EUR
#   which pip size is 0.0001.
#   
#   Moreover, stop level regulates when will occur a margin call. Stop level
#   is a percentage (usually around 50-200%). This indicates a position may
#   meet a margin call (potentially closing position) whenever
#   
#     equity * stop_level < margin.
#
#   Last but not least, freeze level regulates the range that will freeze a
#   position whenever ask/bid prices fall within the aforementioned range.
#   Is means that a take profit, stop loss, or full/partial close orders can
#   NOT be cancelled if TP/SL/close orders fall within
#
#     ask/bid +- freeze_level * pip_size,
#
#   according to the direction of the order (sell/buy).
#
# Initial release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

class Instrument
  attr_accessor :short_name   # Instrument's short name (e.g. CAD).
  attr_accessor :full_name    # Instrument's full name (e.g. Canadian Dollar).
  
  attr_accessor :max_leverage # Maximum leverage.
  
  attr_accessor :pip_size     # Atomic part of this currency.
  attr_accessor :digits       # Number of decimal digits of pip size.
  
  attr_accessor :stop_level   # Margin call when equity * stop_level < margin.
  attr_accessor :freeze_level # Freeze SL/TP within freeze_level * pip_size
  
  attr_accessor :mode         # Time series mode, "OHLC" or "TICK".
  attr_accessor :period       # Time series period, :M1, :M5, ..., :MN1.

  attr_accessor :timestamps   # Time series' timestamps.
  attr_accessor :open, :high, :low, :close    # If @mode == "OHLC".
  attr_accessor :tick                         # If @mode == "TICK".

  # Set attributes for this class.
  def initialize(shortname, fullname, maxleverage, stoplevel, freezelevel,
                 pipsize, decimaldigits)
    short_name   = shortname
    full_name    = fullname
    max_leverage = maxleverage
    stop_level   = stoplevel
    freeze_level = freezelevel
    pip_size     = pipsize
    digits       = decimaldigits
  end

  # Returns true iff data is candlestick (OHLC).
  def is_ohlc?
    mode == "OHLC"
  end
  
  # Returns true iff data is tick (i.e. not candlestick).
  def is_tick?
    mode == "TICK"
  end
end

