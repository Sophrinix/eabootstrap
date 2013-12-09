# SYNOPSIS
#   Simulates the account evolution of an Expert Advisor. The process goes as
#   follows.
#
#   1. Initialization: Configure account.
#   2. Get Instruments: Fetch data from database into instruments' variables.
#   3. Vectorized: Calculates static indicators.
#   4. Before Ticks: Preparation for `tick' loop.
#   5. Tick: Simulates the EA tick-by-tick.
#   6. After Ticks: Executes immediately after `tick' loop.
#
# Initial release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

# Libraries.
require 'rinruby'                        # R integration with Ruby.
require 'pg'                             # Postgres database.

# Dependencies on local files.
load 'simulator.rb'
load 'instrument.rb'

class ExpertAdvisor < Simulator
  attr_reader :eurusd, :x, :y

  # Constructor: initialize super-class, prepare instruments, calculate static
  # indicators, and calls begin-tick-end structure.
  def initialize(initial_balance, account_leverage, account_currency)
    super(initial_balance, account_leverage, account_currency) 
    @x = true
    @y = true

    # R environment.
    R.quit
    @renv = RinRuby.new(echo = false, interactive = false)
    
    # TODO: cronometer these computing times.
    get_instruments                      # Fetch and register instruments.
    vectorized                           # Calculate static indicators.

    before_ticks                         # BEGIN-tick-end.
    until reached_end?                   # begin-TICK-end.
      tick
      execute_scheduled_orders
      advance_next_cursor
    end
    after_ticks                          # begin-tick-END.
  end

  # Fetch data from the database into instruments. (Remember use_instrument).
  def get_instruments
    @eurusd = Instrument.new("EURUSD", "D1", :shift => 10)
    use_instrument(@eurusd)
  end
  
  # After loading the complete dataset in `data_source', you can create new
  # static indicators using Ruby or specialized tools like R and Matlab.
  def vectorized
    @renv.assign "open", [0.01, 0.02, 0.03, 0.04, 0.05]
    @renv.eval <<EOF
  usePackage <- function(p) {
    if (!is.element(p, installed.packages()[,1]))
      install.packages(p, dep = TRUE)
    require(p, quietly = TRUE, character.only = TRUE)
  }

  usePackage('RPostgreSQL')  # database
  #usePackage('MASS')         # truehist
  #usePackage('zoo')          # dependency
  #usePackage('TTR')          # technical trading rules
  #usePackage('fTrading')     # technical trading analysis
  #usePackage('forecast')
  
  driver <- dbDriver('PostgreSQL')
  con <- dbConnect(driver, dbname='eabootstrap')
  result <- dbSendQuery(con, 'SELECT * FROM eurusd_d1')
  df <- fetch(result, n=-1)
  
  close <- df$close
  r <- diff(log(close))

  #png('grafico.png')
  #truehist(r)
  #dev.off()

  #sma <- SMA(close, n=10)
  #print(sma)
  
  dbDisconnect(con)
  dbUnloadDriver(driver)
EOF
    logreturns = @renv.pull('r')
    #sma = @renv.sma[9..15]
    #puts "#{sma}"
  end
  
  # After `vectorized' gets static indicators ready-to-use, the begin-tick-end
  # structure comes to light. This is then the first one to be executed.
  def before_ticks
    puts "<begin>"
  end
  
  # `tick' also makes part of the begin-tick-end structure, it processes all
  # the ticks in a loop ranging from the very first up to the very last tick
  # stepping depending on the calculation method.
  def tick
    print "."

    if x then
      send_order(@eurusd, "long", 0.01)
      @x = false
    end

    if y && !x then
      close_position(@account.positions.first)
      @y = false
    end
  end
  
  # This is the last part of the begin-tick-end structure, it is immediately
  # executed after all the tickets are processed. Its purpose is to process
  # analysis and close opened streams.
  def after_ticks
    puts "\n<end>"
  end
end

# Run expert advisor.
initial_balance  = 15000
account_leverage = 100
account_currency = "USD"
ExpertAdvisor.new(initial_balance, account_leverage, account_currency)
