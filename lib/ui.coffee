EventEmitter = require('events').EventEmitter
readline = require 'readline'
tty = require 'tty'

ansi = require './ansi'

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
        gameUI.destroy()
        @games.splice gameI, 1
      else
        gameUI.drawField()


class GameUI
  @header: -> [ [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
                [1, 1, 1, 1, 1, 1, 1, 1, 1, 1] ]
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
    @head = GameUI.header()
    @offsetX = 0
    @game.on 'draw', (field) => @drawField field
    @game.on 'new pice', (pices) => @drawHead pices
    @game.on 'game over', => @draw ['------GAME OVER-----'], 0, 10

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
    @draw field, 0, @head.length
    @field = field

  drawHead: (pice) ->
    @draw @head, 0, 0
    @draw ["#{@game.score or 1337} @ #{@game.level or 666}"], 1, 1
    @draw pice[0], 1, 3

  destroy: ->
    @game.removeAllListeners()
    @.removeAllListeners()


class Input extends EventEmitter
  constructor: ->
    rint = readline.createInterface process.stdin, {}
    rint.input.on 'keypress', (char, key) =>
      @emit key.name if key?
    tty.setRawMode true

module.exports = {MainUI, GameUI, Input}
