emptyLine = -> [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
jPice = -> [ [1, 1, 1]
           , [0, 0, 1] ]
lPice = -> [ [1, 1, 1]
           , [1, 0, 0] ]
oPice = -> [ [1, 1]
           , [1, 1] ]
iPice = -> [ [1, 1, 1, 1] ]
zPice = -> [ [1, 1, 0]
           , [0, 1, 1] ]
sPice = -> [ [0, 1, 1]
           , [1, 1, 0] ]
tPice = -> [ [1, 1, 1]
           , [0, 1, 0] ]
pices = [ jPice, lPice, oPice, iPice, zPice, sPice, tPice ]

addToMatrix = (m1, m2, offset) ->
    for row, y in m2
      for cell, x in row when cell isnt 0
        m1[offset.y + y][offset.x + x] = cell

class Pice
  constructor: (@_matrix) ->
    @position = x: 4, y: 0

  rotate: (r) ->
    @_matrix = for x in [0..@_matrix[0].length-1]
      (@_matrix[y][x] for y in [@_matrix.length-1..0])

  getBounds: ->
    w: @position.x
    n: @position.y
    e: @position.x + @_matrix[0].length
    s: @position.y + @_matrix.length

class Game
  chars: {0:'\u2588', 1:' '}

  constructor: ->
    @_field = (emptyLine() for x in [0..20])
    @_newPice()

  start: ->
    @_timer = setInterval (=> @_moveY 1), 200

  stop: ->
    clearInterval @_timer

  getField: ->
    (row.concat() for row in @_field)

  _newPice: ->
    @_pice = new Pice pices[Math.round Math.random() * (pices.length-1)]()

  _collisionX: (pice, move) ->
    matrix = pice._matrix
    offset = pice.position
    for row, y in matrix
      for cell, x in row when cell isnt 0
        if @_field[offset.y + y][offset.x + x + move] isnt 0
          return 0
    move

  _collisionY: (pice, move) ->
    if pice.getBounds().s + move > @_field.length
      return 0
    matrix = pice._matrix
    offset = pice.position
    for row, y in matrix
      for cell, x in row when cell isnt 0
        if @_field[offset.y + y + move][offset.x + x] isnt 0
          return 0
    move

  _moveX: (move) ->
    moved = @_collisionX @_pice, move
    @_pice.position.x += moved
    @_draw()
    moved

  _moveY: (move) ->
    moved = @_collisionY @_pice, move
    if moved is 0
      @_addToField @_pice._matrix, @_pice.position
      @_newPice()
    else
      @_pice.position.y += moved
    @_draw()
    moved

  _drop: ->
    m = 1
    m = @_moveY 1 while m

  _addToField: (matrix, offset) ->
    addToMatrix @_field, matrix, offset
    @_checkLines()
  
  _checkLines: ->
    for row, nr in @_field
      do (row) =>
        for cell in row when cell is 0
          return
        @_clearLine nr

  _clearLine: (nr) ->
    console.log "clear #{nr}"
    @_field.splice nr, 1
    @_field.splice 0, 0, emptyLine()

  _draw: ->
    field = @getField()
    addToMatrix field, @_pice._matrix, @_pice.position
    str = (row.join '' for row in field).join('\n')
    str = str.replace(new RegExp(v, 'g'), char) for v,char of @chars
    process.stdout.cursorTo 0, 0
    process.stdout.write str
    #console.dir @_field
    #console.dir @_pice.position

module.exports =
  Pice: Pice
  Game: Game

if require.main is module
  game = new Game

  keys =
    up: -> game._pice.rotate 1
    down: -> game._moveY 1
    left: -> game._moveX -1
    right: -> game._moveX 1
    space: -> game._drop()
    escape: -> process.exit()
  rint = require('readline').createInterface process.stdin, {}
  rint.input.on 'keypress', (char, key) ->
    if key?
      keys[key.name]?()

  require('tty').setRawMode true

  game.start()
