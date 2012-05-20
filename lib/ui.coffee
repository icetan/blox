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
        gameUI.draw()


class GameUI
  @chars:
    0: '  '
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
    @game.on 'draw', (@draw = (field) =>
      field ?= @field
      for row, y in field
        line = (GameUI.chars[x] for x in row).join ''
        process.stdout.cursorTo @offsetX, y
        process.stdout.write line
      @field = field
    )
    @game.on 'game over', (@gameOver = =>
      process.stdout.cursorTo @offsetX, 10
      process.stdout.write '------GAME OVER-----'
    )

  destroy: ->
    @game.removeListener 'draw', @draw
    @game.removeListener 'game over', @gameOver


class Input extends EventEmitter
  constructor: ->
    rint = readline.createInterface process.stdin, {}
    rint.input.on 'keypress', (char, key) =>
      @emit key.name if key?
    tty.setRawMode true

module.exports = {MainUI, GameUI, Input}
