socketIO = require 'socket.io'

class Server
  constructor: (port) ->
    @io = socketIO.listen port
    @_initListeners()
  
  _initListeners: ->
    @io.sockets.on 'connection', (socket) ->
      socket.on 'new player', (data) ->
        socket.set 'nick', data.nick, ->
          socket.broadcast.emit 'new player', data.nick
      socket.on 'change', (field) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'change', nick, field
      socket.on 'lose', ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'lose', nick
      socket.on 'clear', (lines) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'player left', nick

module.exports = {
  Server,
  listen: (port) -> new Server port
}

new Server 13337
