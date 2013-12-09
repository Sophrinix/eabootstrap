WHAT IS?
========

EA bootstrap is an open source platform for quickly and professionally R&amp;D new expert advisors for Forex.

Written as a Ruby API, EA bootstrap provides an environment for quickly building hybrid Expert Advisors and static/dynamic indicators with multiple time-series.
All-in-one, expert advisors can perform calculations on entire time-series (just like R, S-plus, and Matlab traders do) as well as tick-by-tick (just like MetaTrader traders do) in the same program.


STRATEGIES COVERED
==================

The main line is to give foundation to build, evaluate and test any kind of strategy, from Modern Portfolio Theory's Buy and Hold up to High-Frequency Trading.

This is possible because EA bootstrap has an hybrid approach for simulation in two phases:
1) Vectorized
2) Begin-Tick-End.

Vectorized phase enables one to calculate the whole time-series, just like R, S-plus, and Matlab traders do.
The second phase, begin-tick-end, features a loop ranging all the ticks in the time-series, just like MetaTrader traders build their strategies.


LINK WITH OTHER TECHNOLOGIES
============================

Currently, EA bootstrap has total integration with the statistical software R at any development phase.
All R libraries and functions are be available from EA bootstrap.

Moreover, EA bootstrap may link seamlessly in the future with
- S-plus
- Matlab
- Octave
- Mathematica


ANALYSIS
========

Post-analysis are performed in a spreadsheet generated after EA bootstrap's execution.
It has basic statistics, performance, sharpe index, MFE points distribution, and other.


PARAMETER OPTIMIZATION
======================

EA bootstrap comes with an optimizer in order to search for the best parameters for the created expert advisor.
It is possible to optimize measurable functions, like
- expected return
- profit / loss ratio
- maximum drawdown
and others.


POSITION SIZING
===============

Well known position sizing methods are also built-in, ready-to-use in EA bootstrap:
- Kelly criteria;
- Optimal F;
- Secure F;
- Fractional F;
- Dynamic Position Sizing;
- Fixed percentage.

