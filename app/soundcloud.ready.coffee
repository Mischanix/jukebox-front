jukebox.on 'ready', ->
  if window.SC?
    setTimeout (-> jukebox.emit 'SC.ready'), 1
  else
    $SC = ($ '.SC')
    $SC.addEventListener 'load', ->
      jukebox.emit 'SC.ready'

jukebox.on 'SC.ready', ->
  SC.initialize client_id: '7b6445a9fb7d97c3da1310e1b561da79'
  SC.stream '/tracks/110976946',
    whileplaying: ->
      if this.duration > 0
        jukebox.emit 'playback.progress', this.position, this.duration
    onfinish: ->
      jukebox.emit 'notification', 'playing some more tunes'
    (sound) ->
      jukebox.data 'SC.sound', sound
      ($ 'a.verb.mute').addEventListener 'click', ->
        sound.play()
        jukebox.emit 'notification', 'playing some tunes'
  jukebox.emit 'notification', 'soundcloud is ready'
