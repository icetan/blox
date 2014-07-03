EventEmitter = require('events').EventEmitter
io = require 'socket.io-client'

class Client extends EventEmitter
  @count: 0

  constructor: (@nick, game, addr) ->
    throw "Must specify nickname" if not @nick
    @_players = {}
    @_socket = io.connect addr
    # Listen to server events
    @_socket.on 'new player', (data) =>
      {nick, field} = data
      remote = new RemoteGame @_socket, nick
      remote.on 'clear', (lines) ->
        game.addLines lines
      @_players[nick] = remote
      @emit 'new player', remote
      remote.draw nick, field if field?
    @_socket.on 'player left', (nick) =>
      @removeRemote nick
    @_socket.on 'new game', =>
      @emit 'new game'
      game.reset()
      game.start()
    @_socket.on 'game won by', (nick) =>
      @emit 'game won by', nick
      game.stop()
    @_socket.on 'connect', =>
      @_socket.emit 'new player',
        nick: @nick
        field: game._field
    @_socket.on 'disconnect', =>
      @removeRemote nick for nick of @_players
    @_socket.on 'error', (msg) =>
      throw "error from server: #{msg}"
    # Listen and send game events to server
    game.on 'game over', =>
      @_socket.emit 'game over'
    game.on 'change', (field) =>
      @_socket.emit 'change', field
    game.on 'clear', (lines) =>
      @_socket.emit 'clear', lines

  removeRemote: (nick) ->
    remote = @_players[nick]
    remote.destroy()
    delete @_players[nick]
    @emit 'player left', remote


class RemoteGame extends EventEmitter
  constructor: (@_socket, @nick) ->
    @_socket.on 'game over', (@gameOver = (nick) =>
      @emit 'game over' if nick is @nick
    )
    @_socket.on 'change', (@draw = (nick, field) =>
      @emit 'draw', field if nick is @nick
    )
    @_socket.on 'clear', (@clear = (nick, lines) =>
      @emit 'clear', lines if nick is @nick
    )

  destroy: ->
    @_socket.removeListener 'game over', @gameOver
    @_socket.removeListener 'change', @draw
    @_socket.removeListener 'clear', @clear

module.exports = Client
