socketIO = require 'socket.io'

class Server
  constructor: (port) ->
    @playersLeft = []
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
        socket.set 'nick', nick, =>
          socket.broadcast.emit 'new player', data
      socket.on 'change', (field) =>
        socket.get 'nick', (err, nick) =>
          @players[nick] = field
          socket.broadcast.emit 'change', nick, field
      socket.on 'game over', =>
        socket.get 'nick', (err, nick) =>
          socket.broadcast.emit 'game over', nick
          @playersLeft.splice @playersLeft.indexOf(nick), 1
          console.log "PLAYERS LEFT #{@playersLeft.length}"
          @gameWonBy @playersLeft[0] if @playersLeft.length is 1
      socket.on 'clear', (lines) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', =>
        socket.get 'nick', (err, nick) =>
          delete @players[nick]
          @playersLeft.splice @playersLeft.indexOf(nick), 1
          socket.broadcast.emit 'player left', nick
  
  gameWonBy: (nick) ->
    @io.sockets.emit 'game won by', nick

  newGame: ->
    @playersLeft = (nick for field, nick of @players)
    console.log "PLAYERS LEFT #{@playersLeft.length}"
    @io.sockets.emit 'new game'


module.exports = {
  Server,
  listen: (port) -> new Server port
}

if require.main is module
  port = parseInt process.argv[2]
  new Server port
