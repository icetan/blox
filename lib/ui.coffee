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
    UI.offsetX += 22
    @game.on 'draw', (field) ->
      str = (row.join '' for row in field).join('\n')
      str = str.replace(new RegExp(v, 'g'), char) for v,char of UI.chars
      process.stdout.cursorTo @offsetX, 0
      process.stdout.write str


class Input extends EventEmitter
  constructor: (@_game) ->
    rint = readline.createInterface process.stdin, {}
    rint.input.on 'keypress', (char, key) ->
      @emit key if key?
    tty.setRawMode true

module.exports = {UI, Input}
