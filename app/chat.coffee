jukebox.on 'chat.send', (message) ->
  if message.trim().length > 0
    jukebox.emit 'chat.show', jukebox.data('user'), message