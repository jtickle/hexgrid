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

HexMath =

  # Coordinate System Transforms

  worldToHex: (r, pos) =>
    [x,y] = pos
    HexMath.hexRound [
      x * 2/3 / r,
      (-x/3 + Math.sqrt(3)/3 * y) / r
    ]

  hexCenterToWorld: (r, hex) =>
    [hq,hr] = hex
    x = r * 3/2 * hq
    y = r * Math.sqrt(3) * (hr + hq/2)
    [x,y]

  hexCornerToWorld: (r, hex, corner) =>
    [hq,hr] = hex
    [cx,cy] = HexMath.hexCenterToWorld(r, hex)
    theta = Math.PI / 180 * (60 * ((6 - corner) % 6))

    [cx + r * Math.cos(theta),
     cy + r * Math.sin(theta)]

  hexToCube: (h) =>
    x = h[0]
    z = h[1]
    y = -x-z
    [x,y,z]

  cubeToHex: (c) =>
    [q,_,r] = c
    [q,r]

  # Cube Math

  lerp: (a, b, t) =>
    a + (b - a) * t

  cubeLerp: (a, b, t) =>
    [aX,aY,aZ] = a
    [bX,bY,bZ] = b
    [HexMath.lerp(aX, bX, t),
     HexMath.lerp(aY, bY, t),
     HexMath.lerp(aZ, bZ, t)]

  cubeDistance: (a, b) =>
    [aX,aY,aZ] = a
    [bX,bY,bZ] = b
    (Math.abs(aX - bX) + Math.abs(aY - bY) + Math.abs(aZ - bZ)) / 2

  cubeRound: (c) =>
    [x,y,z] = c
    rx = Math.round(x)
    ry = Math.round(y)
    rz = Math.round(z)

    dx = Math.abs(rx - x)
    dy = Math.abs(ry - y)
    dz = Math.abs(rz - z)

    if dx > dy and dx > dz
      rx = -ry-rz
    else if dy > dz
      ry = -rx-rz
    else
      rz = -rx-ry

    [rx, ry, rz]

  # Hex Math

  hexRound: (h) =>
    HexMath.cubeToHex HexMath.cubeRound HexMath.hexToCube h

  hexDistance: (a, b) =>
    HexMath.cubeDistance HexMath.hexToCube(a), HexMath.hexToCube(b)

  createHexLine: (a, b) =>
    n = HexMath.hexDistance(a, b)

    HexMath.cubeToHex HexMath.cubeRound HexMath.cubeLerp(
      HexMath.hexToCube(a),
      HexMath.hexToCube(b),
      (1.0/n) * i
    ) for i in [0..n]


module.exports = HexMath
