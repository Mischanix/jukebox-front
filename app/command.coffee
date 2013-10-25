# /queue command & response handler
jukebox.on 'command.queue', ->
  jukebox.emit 'net.send', 'queue.info'

jukebox.on 'net.queue.tracks', (data) ->
  n = 0
  data.queue.forEach (song) ->
    n += 1
    jukebox.emit 'notification', n + '. ' + song.artist + ' - ' + song.title
