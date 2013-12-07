# SYNOPSIS
#   Provides a set of position sizing methods featuring
#   - Kelly criteria
#   - Optimal F
#   - Secure F
#   - Fractional F
#   - Percent (from available margin).
# 
# First release: Cássio Jandir Pagnoncelli (cassiopagnoncelli@gmail.com)
# Licence: MIT.
#

class PositionSizing
  attr_accessor :account          # Reference to Account.
  
  # Point to Account object so that calculations can be performed.
  def initialize(account_ref)
    account = account_ref
  end
 
  # Calculates the ammount of equity to allocate into `instrument'.
  # `value' ranges from 0 up to 1, where
  #   0 stands for the minimum allocation possible (minimum lot size)
  #   1 stands for the maximum allocation possible not immediately meeting
  #   margin call.
  def percent(instrument, value)
  end

  # Calculates the Kelly's criteria.
  def kelly(instrument)
  end

  # Calculates the Optimal F, Secure F, and Fractional F criteria.
  # 
  # Optimal F is a slightly Kelly's criteria variation considering profit
  # factor instead of profit and loss.
  #
  # Secure F takes the second derivative instead of first providing a point
  # where growth acceleration is null.
  #
  # Fractional F combines Optimal F (`percent'==1) and Secure F (`percent'==0)
  # where `percent' tweaks their mixture.
  #
  def optimal_f(instrument)
  end

  def secure_f(instrument)
  end

  def fractional_f(instrument, value)
  end
end
