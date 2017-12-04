floor5 = (n) ->
  Math.floor(n * 1000) / 1000

module.exports = class Stats
  constructor: (@timer, @stats) ->
    @reset 0

  reset: (currentSecond) =>
    @currentSecond = currentSecond
    @accumulators = @stats.reduce ((acc, val) -> acc[val] = 0; acc), {}
    @counts = @stats.reduce ((acc, val) -> acc[val] = 0; acc), {}

  accumulate: (stat, val) =>
    @counts[stat]++
    @accumulators[stat] += val

  time: (stat, fn) =>
    @accumulate(stat, @timer.time(fn))

  getAverage: (stat) =>
    floor5 @accumulators[stat] / @counts[stat]
