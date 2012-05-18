Client = require './client'
{MainUI, GameUI, Input} = require './ui'
{Game} = require './game'

if require.main is module
  nick = process.argv[2]
  addr = process.argv[3]
  if not addr?
    # if no URL is given, start a server
    require('./server').listen 13337
    addr = 'http://localhost:13337'
  game = new Game
  keys =
    up: -> game.rotate()
    down: -> game.down()
    left: -> game.left()
    right: -> game.right()
    ' ': -> game.drop()
    k: -> game.rotate()
    j: -> game.down()
    h: -> game.left()
    l: -> game.right()
    i: -> game.drop()
    escape: -> process.exit()
  ui = new MainUI
  ui.addGame game

  client = new Client nick, game, addr
  client.on 'new player', (remote) ->
    ui.addGame remote
    remote.on 'clear', (lines) ->
      game.addLines lines
  client.on 'player left', (remote) ->
    ui.removeGame remote
  client.on 'game start', ->
    game.start()
  client.on 'game end', ->
    game.stop()
    game.reset()

  input = new Input
  input.on k, v for k, v of keys
