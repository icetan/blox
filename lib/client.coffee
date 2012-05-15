EventEmitter = require('events').EventEmitter
io = require 'socket.io-client'

class Client extends EventEmitter
  @count: 0

  constructor: (@nick, game, addr) ->
    @_players = {}
    @_socket = io.connect addr
    @_socket.on 'new player', (data) =>
      {nick, field} = data
      remote = new RemoteGame @_socket, nick
      @_players[nick] = remote
      @emit 'new player', remote
      remote.draw nick, field if field?
    @_socket.on 'player left', (nick) =>
      remote = @_players[nick]
      remote.destroy()
      delete @_players[nick]
      @emit 'player left', remote
    game.on 'game over', =>
      @_socket.emit 'game over'
    game.on 'change', (field) =>
      @_socket.emit 'change', field
    game.on 'clear', (lines) =>
      @_socket.emit 'clear', lines
    @_socket.on 'connect', =>
      @_socket.emit 'new player',
        nick: @nick
        field: game._field


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
