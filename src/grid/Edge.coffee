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

module.exports = class Edge
  constructor: (neighbor) ->
    @neighbors = [neighbor]

  setNeighbor: (neighbor) =>
    if(@neighbors.length >= 2)
      throw 'Neighbor already assigned to side'
    @neighbors.push(neighbor)
    this
  
  getNeighbor: (me) =>
    i = @neighbors.indexOf(me)
    if i < 0
      throw 'Specified side not involved in edge pairing'
    if i > 2
      throw 'Too many sides in edge pairing'
    @neighbors[1-i]

  getHighestPriority: () =>
    if(!@neighbors[1]? or @neighbors[0].priority <= @neighbors[1].priority)
      @neighbors[0]
    else
      @neighbors[1]
