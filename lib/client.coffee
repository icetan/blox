EventEmitter = require('evetns').EventEmitter
io = require 'socket.io-client'

class Client extends EventEmitter
  @count: 0

  constructor: (game, addr) ->
    @_players = {}
    @_socket = io.connect addr or 'http://localhost:13337'
    @_socket.on 'new player', (nick) =>
      remote = @_players[nick] = new RemoteGame @_socket, nick
      @emit 'new player', remote
    @_socket.on 'player left', (nick) =>
      @emit 'player left', @_players[nick]
      delete @_players[nick]
    game.on 'lose', =>
      @_socket.emit 'lose'
    game.on 'change', (field) =>
      @_socket.emit 'change', field
    game.on 'clear', (lines) =>
      @_socket.emit 'clear', lines
    @_socket.emit 'new player', nick: "icetan#{Client.count++}"


class RemoteGame extends EventEmitter
  constructor: (socket, @nick) ->
    socket.on 'lose', (nick) =>
      @emit 'lose' if nick is @nick
    socket.on 'change', (nick, field) =>
      @emit 'draw', field if nick is @nick
    socket.on 'clear', (nick, lines) =>
      @emit 'clear', lines if nick is @nick

module.exports = Client
