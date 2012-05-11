io = require('socket.io').listen 13337

io.sockets.on 'connection', (socket) ->
  socket.on 'new player', (data) ->
    socket.set 'nick', data.nick, ->
      socket.broadcast.emit 'new player', data.nick
  socket.on 'draw', (field) ->
    socket.broadcast.emit 'draw', field
  socket.on 'lose', ->
    socket.get 'nick', (err, nick) ->
      socket.broadcast.emit 'lose', nick
