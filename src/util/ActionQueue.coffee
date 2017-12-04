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

memo = {}

module.exports = class ActionQueue
  constructor: () ->
    @queue = []
    @registration = {}

  registerAction: (action, target) =>
    if !@registration[action]?
      @registration[action] = []
    if @registration[action].indexOf target < 0
      @registration[action].push target
    undefined

  unregisterAction: (action, target) =>
    if !@registration[action]?
      console.log 'action was was not registered', action
      return
    idx = @registration[action].indexOf target
    if idx < 0
      console.log 'target was not registered to action', action, target
      return
    @registration[action].splice idx, 1

  # q(@target.function, args...)
  q: (m...) =>
    @queue.push m

  qfn: (cmd) =>
    if !memo[cmd]?
      memo[cmd] = (m...) => @q cmd, m...
    memo[cmd]

  process: () =>
    while @queue.length > 0
      next = @queue.shift()
      action = next.shift()

      if !@registration[action]?
        console.log 'Action triggered but unregistered', action
        continue
      if @registration[action].length == 0
        console.log 'Action triggered but registration empty', action
        continue

      for target in @registration[action]
        target(next...)
