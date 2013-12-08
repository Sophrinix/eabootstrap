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
  
  attr_accessor :leverage     # Maximum leverage.
  
  attr_accessor :pip_size     # Atomic part of this currency.
  attr_accessor :digits       # Number of decimal digits of pip size.
  
  attr_accessor :stop_level   # Margin call when equity * stop_level < margin.
  attr_accessor :freeze_level # Freeze SL/TP within freeze_level * pip_size
  
  attr_accessor :mode         # Time series mode, "OHLC" or "TICK".
  attr_accessor :period       # Time series period, :M1, :M5, ..., :MN1.

  # Timestamped Univariate Time Series (uts): OHLC (candlestick) or tick data.
  attr_accessor :datetime_uts
  attr_accessor :open_uts, :high_uts, :low_uts, :close_uts # if mode == "OHLC"
  attr_accessor :tick_uts                                  # if mode == "TICK"

  attr_accessor :i            # Cursor for serial accessing.
  
  # Fetch meta-information and quotes from database filling this instance.
  # Also, `options' is hash to catch special parameters:
  # *) :shift stands for the lookback period to reserve, it must match the
  #           greatest lag for the current instrument.
  def initialize(shortname, period, options = {})
    opt = { :shift => 0 }.merge(options)                 # Catch options.
    
    connection = PGconn.open(:dbname => "marketplayer")  # pgres connection.
    
    # Get instrument's meta-information.
    meta_query    = "SELECT * FROM #{shortname.downcase}_meta LIMIT 1;"
    meta          = connection.exec(meta_query)
    @short_name   = meta.first["short_name"]
    @full_name    = meta.first["full_name"]
    @leverage     = meta.first["leverage"]
    @pip_size     = meta.first["pip_size"]
    @digits       = meta.first["digits"]
    @stop_level   = meta.first["stop_level"]
    @freeze_level = meta.first["freeze_level"]

    # Quotes information.
    @mode   = "OHLC"
    @period = period.upcase
    
    # Get quotes.
    quotes_query  = "SELECT * FROM #{shortname.downcase}_#{period.downcase};"
    quotes        = connection.exec(quotes_query)
    @datetime_uts = quotes.column_values(0)
    @open_uts     = quotes.column_values(1)
    @high_uts     = quotes.column_values(2)
    @low_uts      = quotes.column_values(3)
    @close_uts    = quotes.column_values(4)
    
    connection.close                                     # pgres close.

    # Configure cursor.
    @i = opt[:shift]
  end

  # Returns true iff data is candlestick (OHLC).
  def is_ohlc?
    mode == "OHLC"
  end
  
  # Returns true iff data is tick (i.e. not candlestick).
  def is_tick?
    mode == "TICK"
  end

  # Advancing cursor just increments it by 1.
  def advance_cursor
    @i = @i + 1
  end

  # True iff cursor reached its final point.
  def reached_end?
    @i >= @datetime_uts.length
  end

  # Time series access
  def datetime(lag)
    lag >= 0 ? @datetime_uts[@i - lag] : nil
  end

  def open(lag)
    lag >= 0 ? @open_uts[@i - lag]: nil
  end

  def high(lag)
    lag >= 0 ? @high_uts[@i - lag] : nil
  end

  def low(lag)
    lag >= 0 ? @low_uts[@i - lag] : nil
  end

  def close(lag)
    lag >= 0 ? @close_uts[@i - lag] : nil
  end
end

