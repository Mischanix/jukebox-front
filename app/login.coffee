jukebox.on 'ready', ->
  loginState = 'idle'
  loginStates = ['idle', 'logging in', 'error', 'success']
  jukebox.on 'login.perform', (nick, pass) ->
    jukebox.emit 'login.ping' for i in [1..2]
    console.log nick, pass
    jukebox.emit 'net.send', 'login', { nick, pass }