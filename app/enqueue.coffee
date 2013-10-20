jukebox.on 'enqueue', (track) ->
  if not _.isString track
    track = track.toString 10
  jukebox.emit 'net.send', 'queue', {track}
