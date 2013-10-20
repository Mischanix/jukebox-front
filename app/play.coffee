jukebox.on 'player.ready', ->
  jukebox.data 'player.ready', not (true is jukebox.data 'player.ready')
  jukebox.emit 'net.send', 'progress'

jukebox.on 'play', (track, progress) ->
  duration = jukebox.data 'playing.duration'
  if track is jukebox.data 'playing.track'
    (jukebox.data 'SC.sound').setPosition progress
    return
  if true is jukebox.data 'player.ready'
    return if track is ''
    sound = null
    SC.stream '/tracks/' + track,
      whileplaying: ->
        jukebox.emit 'playback.progress', sound.position, duration
      onload: ->
        jukebox.data 'playing.track', track
        if progress isnt 0
          sound.setPosition progress
        sound.play()
      onfinish: ->
        jukebox.data 'playing.track', ''
      (_sound) ->
        sound = _sound
        if (jukebox.data 'SC.sound').stop?
          oldSound = jukebox.data 'SC.sound'
          oldSound.stop()
        jukebox.data 'SC.sound', sound
        sound.load()
  else
    start = Date.now() - progress
    track += '-fake-' + start.toString 10
    jukebox.data 'playing.track', track
    fakePlayerTick = ->
      elapsed = Date.now() - start
      if (true is jukebox.data 'player.ready') or
          (track isnt jukebox.data 'playing.track') or
          (elapsed > duration)
        stopTicking()
        return
      jukebox.emit 'playback.progress', elapsed, duration
    fakePlayer = setInterval fakePlayerTick, 500
    stopTicking = -> clearInterval fakePlayer

jukebox.on 'net.ready', ->
  jukebox.emit 'net.send', 'progress'

jukebox.on 'net.play', (data) ->
  jukebox.data 'playing.link', data.link
  jukebox.data 'playing.artist', data.artist
  jukebox.data 'playing.title', data.title
  jukebox.data 'playing.duration', data.duration
  jukebox.emit 'play', data.track, data.progress
