jukebox.on 'logout', ->
  # just trash the session data and reconnect the websocket
  localStorage.session = ''
  localStorage.secret = ''
  jukebox.emit 'net.reconnect'
