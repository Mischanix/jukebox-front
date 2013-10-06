jukebox.on 'login', (nick, pass) ->
  jukebox.emit 'login.ping' for i in [1..2]
  console.log nick, pass
  jukebox.emit 'net.send', 'login', { nick, pass }

jukebox.on 'net.login.response', (data) ->
  {status, reason} = data
  if status is 'ok'
    jukebox.emit 'login.hide'
  else
    jukebox.emit 'login.error.show', reason
