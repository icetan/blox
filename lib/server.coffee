socketIO = require 'socket.io'

class Server
  constructor: (port) ->
    @playerCount = 0
    @playersLeft = []
    @players = {}
    @io = socketIO.listen port
    @_initListeners()
  
  _initListeners: ->
    @io.sockets.on 'connection', (socket) =>
      for nick, field of @players
        socket.emit 'new player', {nick, field}
      socket.on 'new player', (data) =>
        {nick, field} = data
        @players[nick] = field
        was = @playerCount++
        socket.set 'nick', nick, =>
          socket.broadcast.emit 'new player', data
          @newGame() if was < 2 and @playerCount >= 2
      socket.on 'change', (field) =>
        socket.get 'nick', (err, nick) =>
          @players[nick] = field
          socket.broadcast.emit 'change', nick, field
      socket.on 'game over', =>
        socket.get 'nick', (err, nick) =>
          socket.broadcast.emit 'game over', nick
          @playersLeft.splice @playersLeft.indexOf(nick), 1
          if @playersLeft.length is 1
            @gameWonBy @playersLeft[0]
            setTimeout (=> @newGame()), 3000
      socket.on 'clear', (lines) ->
        socket.get 'nick', (err, nick) ->
          socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', =>
        socket.get 'nick', (err, nick) =>
          @playerCount--
          delete @players[nick]
          @playersLeft.splice @playersLeft.indexOf(nick), 1
          socket.broadcast.emit 'player left', nick
  
  gameWonBy: (nick) ->
    @io.sockets.emit 'game won by', nick

  newGame: ->
    @playersLeft = (nick for field, nick of @players)
    @io.sockets.emit 'new game'


module.exports = {
  Server,
  listen: (port) -> new Server port
}

if require.main is module
  port = parseInt process.argv[2] or 13337
  new Server port
