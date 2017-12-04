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

# Debugging function - shows a stat in the DOM
showStat = (id, n) ->
  document.getElementById('stats-' + id).textContent = n
  undefined

module.exports = class Ui
  constructor: (@state, @draw) ->
    undefined

  registerHandlerWith: (register) =>
    register 'ui.stats.update', @updateStats
    undefined

  updateStats: (stats) =>
    showStat 'fps', stats['render']['count']
    for stat, vals of stats
      showStat stat, vals['average']
    undefined
