# SYNOPSIS
# 
#   Provides an API for managing an account. An account may contain customer
#   informations
#   
#     - base-currency,
#     - leverage,
#     - current position information (balance, equity, and margin),
#     - deal history.
#   
#   Moreover, it is intended to be used in an Expert Advisor or Event Profiler
#   environment. All this information should be provided by broker.
#
# Author: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com).
# Licence: MIT.
#

class Account
  attr_reader   :base_currency                # Base currency.
  attr_accessor :balance, :equity, :margin    # Account position.
  attr_accessor :leverage                     # Leverage information.

  attr_accessor :orders                       # Orders not yet filled.
  attr_accessor :positions                    # Open positions.
  attr_accessor :closed_positions             # Closed positions.
  
  # Sets Account's attributes only.
  def initialize(initial_balance, initial_equity, initial_margin, lev, currcy)
    # Account position / status.
    @balance       = initial_balance
    @equity        = initial_equity
    @margin        = initial_margin
    @leverage      = lev
    @base_currency = currcy

    # Open and closed trades.
    @orders = []
    @positions = []
    @closed_positions = []
  end
  
  # Calculates free margin.
  def free_margin
    equity - margin
  end
end

