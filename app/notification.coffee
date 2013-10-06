jukebox.on 'notification', (msg) ->
  jukebox.emit 'chat.show', '', msg, true
