EventEmitter = require('events').EventEmitter

ansi = require './ansi'
{HandlerMixIn} = require './util'

class MainUI
  constructor: ->
    @games = []

  addGame: (game) ->
    gameUI = new GameUI game
    gameUI.offsetX = @games.length * 24
    @games.push gameUI

  removeGame: (game) ->
    games = @games.concat()
    for gameUI, i in games
      gameI = i - (games.length - @games.length)
      gameUI.offsetX = gameI * 24
      if gameUI.game is game
        gameUI.removeAllHandlers()
        @games.splice gameI, 1
      else
        gameUI.drawField()


class GameUI extends HandlerMixIn
  @chars:
    0: ansi.style ansi.bgblack, '  '
    1: ansi.style ansi.bgwhite, '  '
    2: ansi.style ansi.bgmagenta, '  '
    3: ansi.style ansi.bgblue, '  '
    4: ansi.style ansi.bgred, '  '
    5: ansi.style ansi.bgcyan, '  '
    6: ansi.style ansi.bggreen, '  '
    7: ansi.style ansi.bgyellow, '  '

  constructor: (@game) ->
    @field = [[]]
    @offsetX = 0
    @handle @game, 'draw', @drawField
    @handle @game, 'new pice', @drawHead
    @handle @game, 'game over', -> @draw ['------GAME OVER-----'], 0, 10

  draw: (matrix, offsetX, offsetY) ->
    for row, y in matrix
      if row instanceof Array
        line = (GameUI.chars[x] or x for x in row).join ''
      else
        line = row
      process.stdout.cursorTo @offsetX+offsetX, offsetY+y
      process.stdout.write line

  drawField: (field) ->
    field ?= @field
    @draw field, 0, 4
    @field = field

  drawHead: (pice) ->
    @draw [ '                    '
            '                    '
            '                    '
            '--------------------' ], 0, 0
    # TODO: Add score and level print outs.
    #@draw ["#{@game.score or 1337} @ #{@game.level or 666}"], 1, 0
    @draw pice[0], 0, 0


class Input extends EventEmitter
  constructor: ->
    require('keypress') process.stdin
    process.stdin.on 'keypress', (ch, key) =>
      @emit key.name if key?
    process.stdin.setRawMode true
    process.stdin.resume()

module.exports = {MainUI, GameUI, Input}
