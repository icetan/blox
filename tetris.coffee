EventEmitter = require('events').EventEmitter

emptyLine = ->  [0,0,0,0,0,0,0,0,0,0]
jPice = -> [ [1,1,1]
           , [0,0,1] ]
lPice = -> [ [1,1,1]
           , [1,0,0] ]
oPice = -> [ [1,1]
           , [1,1] ]
iPice = -> [ [1,1,1,1] ]
zPice = -> [ [1,1,0]
           , [0,1,1] ]
sPice = -> [ [0,1,1]
           , [1,1,0] ]
tPice = -> [ [1,1,1]
           , [0,1,0] ]
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

rotateMatrix = (matrix, r) ->
  for x in [0..matrix[0].length-1]
    (matrix[y][x] for y in [matrix.length-1..0])


class Pice
  constructor: (@_matrix, @position) ->
    @position ?= x: 4, y: 0

  rotate: (r) ->
    @_matrix = rotateMatrix @_matrix, r

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
    @_field = (emptyLine() for x in [0..20])
    @_newPice()

  start: (speed) ->
    @stop()
    @_timer = setInterval (=> @_moveY 1), speed or 600

  stop: ->
    clearInterval @_timer

  lose: ->
    @stop()
    @.emit 'lost'

  getField: ->
    (row.concat() for row in @_field)

  _newPice: ->
    @_pice = new Pice pices[Math.round Math.random() * (pices.length-1)]()

  _nextPice: (matrix, offset) ->
    addToMatrix @_field, @_pice._matrix, @_pice.position
    @_checkLines()
    @_newPice()
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

  _drop: ->
    y = 0
    c = false
    c = @_collision {x:0, y:++y} while not c
    if --y > 0
      @_pice.position.y += y
      @_nextPice()

  rotate: (r) ->
    matrix = rotateMatrix @_pice._matrix, 1
    if not matrixCollision @_field, matrix, @_pice.position
      @_pice._matrix = matrix
      @_draw()

  _checkLines: ->
    for row, nr in @_field
      do (row) =>
        if nr is 0 and 1 in row # non black block on first line
          @lose()
          return
        (return) if 0 in row
        @_clearLine nr

  _clearLine: (nr) ->
    @_field.splice nr, 1
    @_field.splice 0, 0, emptyLine()
    @emit 'clear', nr

  _draw: ->
    field = @getField()
    addToMatrix field, @_pice._matrix, @_pice.position
    @emit 'draw', field

module.exports =
  Pice: Pice
  Game: Game

if require.main is module
  chars =
    0:'\u2588\u2588'
    1:'\u2591\u2591'

  game = new Game
  game.on 'lost', ->
    process.exit 0
  game.on 'draw', (field) ->
    str = (row.join '' for row in field).join('\n')
    str = str.replace(new RegExp(v, 'g'), char) for v,char of chars
    process.stdout.cursorTo 0, 0
    process.stdout.write str

  keys =
    k: -> game.rotate 1
    j: -> game._moveY 1
    h: -> game._moveX -1
    l: -> game._moveX 1
    i: -> game._drop()
    escape: -> process.exit()
  rint = require('readline').createInterface process.stdin, {}
  rint.input.on 'keypress', (char, key) ->
    if key?
      keys[key.name]?()

  require('tty').setRawMode true

  game.start()
