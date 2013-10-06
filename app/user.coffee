jukebox.on 'net.user', (user) ->
  for k, v of user
    jukebox.data 'user.' + k, v
