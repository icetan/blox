socketIO = require 'socket.io'

class Server
  constructor: (port, debug) ->
    @playerCount = 0
    @playersLeft = []
    @players = {}
    @io = socketIO.listen port, log:debug or false
    @_initListeners()

  _initListeners: ->
    @io.sockets.on 'connection', (socket) =>
      for nick, field of @players
        socket.emit 'new player', {nick, field}
      socket.on 'new player', (data) =>
        {nick, field} = data
        if @players[nick]?
          socket.emit 'error', "Nick already in use"
          socket.disconnect()
        else
          @players[nick] = field
          was = @playerCount++
        socket.nick = nick
        socket.broadcast.emit 'new player', data
        @newGame() if was < 2 and @playerCount >= 2
      socket.on 'change', (field) =>
        nick = socket.nick
        @players[nick] = field
        socket.broadcast.emit 'change', nick, field
      socket.on 'game over', =>
        nick = socket.nick
        socket.broadcast.emit 'game over', nick
        @playerLost nick
      socket.on 'clear', (lines) ->
        nick = socket.nick
        socket.broadcast.emit 'clear', nick, lines
      socket.on 'disconnect', =>
        nick = socket.nick
        if nick?
          @playerCount--
          delete @players[nick]
          socket.broadcast.emit 'player left', nick
          @playerLost nick

  playerLost: (nick) ->
    @playersLeft.splice @playersLeft.indexOf(nick), 1
    if @playersLeft.length is 1
      @gameWonBy @playersLeft[0]
      setTimeout (=> @newGame()), 3000

  gameWonBy: (nick) ->
    @io.sockets.emit 'game won by', nick

  newGame: ->
    @playersLeft = (nick for field, nick of @players)
    @io.sockets.emit 'new game'


module.exports = {
  Server,
  listen: (port, debug) -> new Server port, debug
}

if require.main is module
  port = parseInt process.argv[2] or 13337
  new Server port
