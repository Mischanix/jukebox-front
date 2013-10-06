jukebox.on 'chat.send', (message) ->
  jukebox.emit 'net.send', 'chat', {message}
  if message.trim().length > 0
    jukebox.emit 'chat.show', jukebox.data('user.nick'), message

jukebox.on 'net.chat.receive', (data) ->
  jukebox.emit 'chat.show', data.nick, data.message
