
EventEmitter = require('events').EventEmitter

emptyLine = -> [0,0,0,0,0,0,0,0,0,0]
brokenLine = ->
  l = [1,1,1,1,1,1,1,1,1,1]
  l[Math.round Math.random() * (l.length-1)] = 0
  l
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
tPice = -> [ [7,7,7]
           , [0,7,0] ]
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
  @random: -> new Pice pices[Math.round Math.random() * (pices.length-1)]()

  constructor: (@_matrix, @position) ->
    @_origMatrix = @_matrix
    @reset() if not @position?

  reset: ->
    @_matrix = @_origMatrix
    @position = x: 4, y: 0

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
    @_maxPices = 1
    @_pices = []
    @running = no
    @reset()

  reset: ->
    @_pice = null
    @_field = (emptyLine() for x in [0...20])
    @_addPice() for x in [0...@_maxPices]
    @_nextPice()

  start: (speed) ->
    @stop()
    @_timer = setInterval (=> @_moveY 1), speed or 600
    @running = yes

  stop: ->
    clearInterval @_timer
    @running = no

  gameOver: ->
    @stop()
    @emit 'game over'

  getField: ->
    (row.concat() for row in @_field)

  _addPice: -> @_pices.push Pice.random()

  _nextPice: ->
    if @_pice?
      addToMatrix @_field, @_pice._matrix, @_pice.position
      @_checkLines()
    @emit 'change', @_field
    @_addPice()
    @_pice = @_pices.shift()
    @canSwap = yes
    @emit 'new pice', (pice._matrix for pice in @_pices)
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
    (return) if not @running
    y = 0
    c = false
    c = @_collision {x:0, y:++y} until c
    if --y > 0
      @_pice.position.y += y
      @_nextPice()

  rotate: ->
    (return) if not @running
    matrix = rotateMatrix @_pice._matrix
    if not matrixCollision @_field, matrix, @_pice.position
      @_pice._matrix = matrix
      @_draw()

  down: -> @_moveY 1 if @running
  left: -> @_moveX -1 if @running
  right: -> @_moveX 1 if @running

  swap: ->
    if @running and @canSwap
      @canSwap = no
      @_pice.reset()
      [@_pice] = @_pices.splice 0, 1, @_pice
      @emit 'new pice', (pice._matrix for pice in @_pices)
      @_draw()

  _checkLines: ->
    lines = 0
    for row, nr in @_field
      do (row) =>
        (return) if 0 in row
        @_clearLine nr
        lines++
    if lines > 0
      @emit 'clear', lines

  _clearLine: (nr) ->
    @_field.splice nr, 1
    @_field.splice 0, 0, emptyLine()
    @emit 'change', @_field
    @_draw()
    
  addLines: (nr) ->
    (return) if not @running
    @_field.splice 0, nr
    @_field.push brokenLine() for x in [0...nr]
    @emit 'change', @_field
    @_draw()

  _draw: ->
    field = @getField()
    addToMatrix field, @_pice._matrix, @_pice.position
    @emit 'draw', field

module.exports =
  Pice: Pice
  Game: Game

