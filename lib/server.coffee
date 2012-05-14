socketIO = require 'socket.io'

class Server
  constructor: (port) ->
    @players = {}
    @io = socketIO.listen port
    @_initListeners()
  
  _initListeners: ->
    @io.sockets.on 'connection', (socket) =>
      for nick, field of @players
        console.log "sending player info for #{nick}"
        socket.emit 'new player', {nick, field}
      socket.on 'new player', (data) =>
        {nick, field} = data
        @players[nick] = field
        socket.set 'nick', nick, ->
          socket.broadcast.emit 'new player', data
      socket.on 'change', (field) =>
        socket.get 'nick', (err, nick) =>
          @players[nick] = field
          socket.broadcast.emit 'change', nick, field
      socket.on 'game over', ->
        socket.set 'lost', true
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'game over', nick
      socket.on 'clear', (lines) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', =>
        socket.get 'nick', (err, nick) =>
          delete @players[nick]
          socket.broadcast.emit 'player left', nick

module.exports = {
  Server,
  listen: (port) -> new Server port
}

new Server 13337
