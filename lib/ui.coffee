EventEmitter = require('events').EventEmitter
readline = require 'readline'
tty = require 'tty'

class UI
  @offsetX = 0
  @chars:
    0:'\u25A0\u25A0'
    1:'  '

  constructor: (@game) ->
    @offsetX = UI.offsetX
    UI.offsetX += 24
    @game.on 'draw', (field) =>
      for row, y in field
        line = row.join ''
        line = line.replace(new RegExp(v, 'g'), char) for v,char of UI.chars
        process.stdout.cursorTo @offsetX, y
        process.stdout.write line
    @game.on 'game over', =>
      process.stdout.cursorTo @offsetX, 10
      process.stdout.write '------GAME OVER-----'


class Input extends EventEmitter
  constructor: ->
    rint = readline.createInterface process.stdin, {}
    rint.input.on 'keypress', (char, key) =>
      @emit key.name if key?
    tty.setRawMode true

module.exports = {UI, Input}
