#
# HexGrid - Copyright (C) 2016  Jeffrey W. Tickle
#
# The CoffeeScript code in this page is free software: you can
# redistribute it and/or modify it under the terms of the GNU
# General Public License (GNU GPL) as published by the Free Software
# Foundation, either version 3 of the License, or (at your option)
# any later version.  The code is distributed WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU GPL for more details.
#
# As additional permission under GNU GPL version 3 section 7, you
# may distribute non-source (e.g., minimized or compacted) forms of
# that code without the copy of the GNU GPL normally required by
# section 4, provided you include this license notice and a URL
# through which recipients can access the Corresponding Source.
#

floor5 = (n) ->
  Math.floor(n * 1000) / 1000

module.exports = class Stats
  constructor: (@timer, @stats) ->
    @reset()

  snapshot: () =>
    @stats.reduce ((acc, val) =>
      acc[val] =
        total: @accumulators[val]
        count: @counts[val]
        average: @getAverage val
      return acc
      ), {}

  reset: () =>
    @accumulators = @stats.reduce ((acc, val) -> acc[val] = 0; acc), {}
    @counts = @stats.reduce ((acc, val) -> acc[val] = 0; acc), {}

  accumulate: (stat, val) =>
    @counts[stat]++
    @accumulators[stat] += val

  time: (stat, fn) =>
    @accumulate(stat, @timer.time(fn))

  getAverage: (stat) =>
    floor5 @accumulators[stat] / @counts[stat]
