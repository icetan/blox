Client = require './client'
{MainUI, GameUI, Input} = require './ui'
{Game} = require './game'

start = (nick, addr) ->
  if not addr?
    # if no URL is given, start a server
    server = require('./server').listen 13337
    addr = 'localhost'
  game = new Game
  keys =
    s: -> server?.newGame()
    up: -> game.rotate()
    down: -> game.down()
    left: -> game.left()
    right: -> game.right()
    space: -> game.drop()
    k: -> game.rotate()
    j: -> game.down()
    h: -> game.left()
    l: -> game.right()
    i: -> game.drop()
    u: -> game.swap()
    escape: -> process.exit()
    q: -> process.exit()
  ui = new MainUI
  ui.addGame game

  client = new Client nick, game, "http://#{addr}:13337"
  client.on 'new player', (remote) ->
    ui.addGame remote
  client.on 'player left', (remote) ->
    ui.removeGame remote

  input = new Input
  input.on k, v for k, v of keys


module.exports = start

if require.main is module
  nick = process.argv[2]
  addr = process.argv[3]
  start nick, addr
