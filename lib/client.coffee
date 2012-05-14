EventEmitter = require('events').EventEmitter
io = require 'socket.io-client'

class Client extends EventEmitter
  @count: 0

  constructor: (@nick, game, addr) ->
    console.log "I'm #{@nick}"
    @_socket = io.connect addr or 'http://localhost:13337'
    @_socket.on 'new player', (data) =>
      {nick, field} = data
      remote = new RemoteGame @_socket, nick
      @emit 'new player', remote
      remote.emit 'draw', field if field?
    game.on 'game over', =>
      @_socket.emit 'game over'
    game.on 'change', (field) =>
      @_socket.emit 'change', field
    game.on 'clear', (lines) =>
      @_socket.emit 'clear', lines
    @_socket.emit 'new player',
      nick: @nick
      field: game._field


class RemoteGame extends EventEmitter
  constructor: (socket, @nick) ->
    socket.on 'game over', (nick) =>
      @emit 'game over' if nick is @nick
    socket.on 'player left', (nick) =>
      @emit 'player left' if nick is @nick
    socket.on 'change', (nick, field) =>
      @emit 'draw', field if nick is @nick
    socket.on 'clear', (nick, lines) =>
      console.log "#{nick} cleard #{lines} lines"
      @emit 'clear', lines if nick is @nick

module.exports = Client
