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

Space = require 'grid/Space'

mkCol = (grid, pos) ->
  new Space(pos, 'Empty', grid)

mkRow = (grid, r) ->
  maxv = grid.maxv
  first = -maxv - Math.min(0, r)
  last  =  maxv - Math.max(0, r)
  (mkCol(grid, [q, r]) for q in [first .. last])

module.exports = class Grid
  constructor: (@radius) ->
    @maxv     = @radius - 1
    @diameter = (@radius * 2) + 1

    @grid = (mkRow(this, r) for r in [-@maxv .. @maxv])

    @selected = null

    for I, i in @grid
      for J, j in I
        J.connect(this)

  getSpace: (hex, connectChildren = true) =>
    [q, r] = hex
    i = r + @maxv
    j = q + @maxv + Math.min(0, r)

    if i < 0 or j < 0 or i >= @grid.length or j >= @grid[i].length
      ts = new Space([q, r], 'OutOfBounds')
      if connectChildren then ts.connect(this)
      ts
    else
      @grid[i][j]

  toggleSelect: (pos) =>
    sp = @getSpace(pos)

    if(@selected?)
      @selected.selected = false

    if sp.type == 'OutOfBounds' or @selected == sp
      @selected = null
      return
 
    @selected = sp
    @selected.selected = true
