socketIO = require 'socket.io'

class Server
  constructor: (port) ->
    @players = {}
    @io = socketIO.listen port
    @_initListeners()
  
  _initListeners: ->
    @io.sockets.on 'connection', (socket) =>
      socket.on 'new player', (data) ->
        {nick, field} = data
        socket.set 'nick', nick, ->
          socket.broadcast.emit 'new player', data
      socket.on 'change', (field) =>
        socket.get 'nick', (err, nick) =>
          @players[nick] = field
          socket.broadcast.emit 'change', nick, field
      socket.on 'lose', ->
        socket.set 'lost', true, ->
          socket.get 'nick', (err, nick) ->
            socket.broadcast.emit 'lose', nick
      socket.on 'clear', (lines) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', =>
        socket.get 'nick', (err, nick) =>
          delete @player[nick]
          socket.broadcast.emit 'player left', nick
      for nick, field of @players
        socket.emit 'new player', {nick, field}

module.exports = {
  Server,
  listen: (port) -> new Server port
}

new Server 13337
