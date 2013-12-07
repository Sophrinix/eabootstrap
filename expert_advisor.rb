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
  def initialize
    # Super-class initialization.
    initial_balance  = 15000
    account_leverage = 100
    account_currency = "USD"
    super(initial_balance, account_leverage, account_currency) 
    
    get_instruments                      # Fetch and register instruments.
    vectorized                           # Calculate static indicators.

    before_ticks                         # BEGIN-tick-end.
    until reach_end?                     # begin-TICK-end.
      tick
      @ticket = @ticket + 1
    end
    after_ticks                          # begin-tick-END.
  end

  # Fetch data from the database into instruments.
  # NOTE: Don't forget to register utilized instruments with `use_instrument'.
  def get_instruments
    connection = PGconn.open(:dbname => "marketplayer")
    
    # Get instrument's meta-information.
    meta         = connection.exec("SELECT * FROM eurusd_meta LIMIT 1;")
    short_name   = meta.first["short_name"]
    full_name    = meta.first["full_name"]
    leverage     = meta.first["leverage"]
    pip_size     = meta.first["pip_size"]
    digits       = meta.first["digits"]
    stop_level   = meta.first["stop_level"]
    freeze_level = meta.first["freeze_level"]
    
    # Get quotes.
    quotes = connection.exec("SELECT * FROM eurusd_d1;")
    date   = quotes.column_values(0)
    open   = quotes.column_values(1)
    high   = quotes.column_values(2)
    low    = quotes.column_values(3)
    close  = quotes.column_values(4)
    
    # Build instrument.
    eurusd = Instrument.new(short_name, full_name, leverage, stop_level,
                            freeze_level, pip_size, digits)
    eurusd.timestamps = date
    eurusd.open       = open
    eurusd.high       = high
    eurusd.low        = low
    eurusd.close      = close
    
    use_instrument(eurusd)
  end
  
  # After loading the complete dataset in `data_source', you can create new
  # static indicators using Ruby or specialized tools like R and Matlab.
  def vectorized
    R.quit
    renv = RinRuby.new(echo = false, interactive = false)

    renv.assign "open", [0.01, 0.02, 0.03, 0.04, 0.05]
    renv.eval <<EOF
  usePackage <- function(p) {
    if (!is.element(p, installed.packages()[,1]))
      install.packages(p, dep = TRUE)
    require(p, quietly = TRUE, character.only = TRUE)
  }

  usePackage('RPostgreSQL')
  usePackage('MASS')
  
  driver <- dbDriver('PostgreSQL')
  con <- dbConnect(driver, dbname='marketplayer')
  result <- dbSendQuery(con, 'SELECT * FROM eurusd_d1')
  df <- fetch(result, n=-1)
  
  close <- df$close
  r <- diff(log(close))

  png('/tmp/grafico.png')
  truehist(r)
  dev.off()
  
  dbDisconnect(con)
  dbUnloadDriver(driver)
EOF
    logreturns = renv.pull('r')
  end
  
  # After `vectorized' gets static indicators ready-to-use, the begin-tick-end
  # structure comes to light. This is then the first one to be executed.
  def before_ticks
    print "begin"
  end
  
  # `tick' also makes part of the begin-tick-end structure, it processes all
  # the ticks in a loop ranging from the very first up to the very last tick
  # stepping depending on the calculation method.
  def tick
    print "."
  end
  
  # This is the last part of the begin-tick-end structure, it is immediately
  # executed after all the tickets are processed. Its purpose is to process
  # analysis and close opened streams.
  def after_ticks
    puts "end"
  end
end

ExpertAdvisor.new
