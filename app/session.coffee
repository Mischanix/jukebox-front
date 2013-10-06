jukebox.on 'net.ready', ->
  session = localStorage.session
  secret = localStorage.secret
  jukebox.emit 'net.send', 'session', { session, secret }
jukebox.on 'net.session.response', (data) ->
  console.log 'storing session response...'
  localStorage.session = data.session
  localStorage.secret = data.secret
  jukebox.emit 'net.send', 'session.updated'
