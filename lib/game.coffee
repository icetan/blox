
EventEmitter = require('events').EventEmitter

emptyLine = -> [0,0,0,0,0,0,0,0,0,0]
brokenLine = -> [1,1,1,1,1,1,0,1,1,1]
jPice = -> [ [1,1,1]
           , [0,0,1] ]
lPice = -> [ [2,2,2]
           , [2,0,0] ]
oPice = -> [ [3,3]
           , [3,3] ]
iPice = -> [ [4,4,4,4] ]
zPice = -> [ [5,5,0]
           , [0,5,5] ]
sPice = -> [ [0,6,6]
           , [6,6,0] ]
tPice = -> [ [6,6,6]
           , [0,6,0] ]
pices = [ jPice, lPice, oPice, iPice, zPice, sPice, tPice ]

matrixCollision = (m1, m2, offset) ->
  for row, y in m2
    for cell, x in row when cell isnt 0
      if m1[offset.y + y][offset.x + x] isnt 0
        return true
  false

addToMatrix = (m1, m2, offset) ->
  for row, y in m2
    for cell, x in row when cell isnt 0
      m1[offset.y + y][offset.x + x] = cell

rotateMatrix = (matrix) ->
  for x in [0..matrix[0].length-1]
    (matrix[y][x] for y in [matrix.length-1..0])


class Pice
  constructor: (@_matrix, @position) ->
    @position ?= x: 4, y: 0

  rotate: ->
    @_matrix = rotateMatrix @_matrix

  getBounds: ->
    width = @_matrix[0].length
    height = @_matrix.length
    w: @position.x
    n: @position.y
    e: @position.x + width
    s: @position.y + height
    width: width
    height: height


class Game extends EventEmitter
  constructor: ->
    @reset()

  reset: ->
    @_pice = null
    @_field = (emptyLine() for x in [0...20])
    @_nextPice()

  start: (speed) ->
    @stop()
    @_timer = setInterval (=> @_moveY 1), speed or 600

  stop: ->
    clearInterval @_timer

  gameOver: ->
    @stop()
    @emit 'game over'

  getField: ->
    (row.concat() for row in @_field)

  _nextPice: ->
    if @_pice?
      addToMatrix @_field, @_pice._matrix, @_pice.position
      @_checkLines()
      @emit 'change', @_field
    @_pice = new Pice pices[Math.round Math.random() * (pices.length-1)]()
    if @_collision {x:0, y:0}
      @gameOver()
    else
      @_draw()
  
  _collision: (offset) ->
    bb = @_pice.getBounds()
    if bb.s + offset.y > @_field.length
      true
    else
      matrixCollision @_field, @_pice._matrix
      , {x:bb.w+offset.x, y:bb.n+offset.y}

  _moveX: (move) ->
    if not @_collision {x:move, y:0}
      @_pice.position.x += move
      @_draw()

  _moveY: (move) ->
    if not @_collision {x:0, y:move}
      @_pice.position.y += move
      @_draw()
    else
      @_nextPice()

  drop: ->
    y = 0
    c = false
    c = @_collision {x:0, y:++y} while not c
    if --y > 0
      @_pice.position.y += y
      @_nextPice()

  rotate: ->
    matrix = rotateMatrix @_pice._matrix
    if not matrixCollision @_field, matrix, @_pice.position
      @_pice._matrix = matrix
      @_draw()

  down: -> @_moveY 1
  left: -> @_moveX -1
  right: -> @_moveX 1

  _checkLines: ->
    lines = 0
    for row, nr in @_field
      do (row) =>
        (return) if 0 in row
        @_clearLine nr
        lines++
    @emit 'clear', lines if lines

  _clearLine: (nr) ->
    @_field.splice nr, 1
    @_field.splice 0, 0, emptyLine()
    
  addLines: (nr) ->
    @_field.splice 0, nr
    @_field.push brokenLine() for x in [0...nr]

  _draw: ->
    field = @getField()
    addToMatrix field, @_pice._matrix, @_pice.position
    @emit 'draw', field

module.exports =
  Pice: Pice
  Game: Game

