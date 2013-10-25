jukebox.on 'chat.send', (message) ->
  if message[0] is '/'
    jukebox.emit 'command.' + message.substr 1
  else
    jukebox.emit 'net.send', 'chat', {message}
    if message.trim().length > 0
      jukebox.emit 'chat.show', jukebox.data('user.nick'), message

jukebox.on 'net.chat.receive', (data) ->
  if data.nick isnt jukebox.data 'user.nick'
    jukebox.emit 'chat.show', data.nick, data.message
