jukebox.on 'ready', ->
  if window.SC?
    setTimeout (-> jukebox.emit 'SC.ready'), 1
  else
    $SC = ($ '.SC')
    $SC.addEventListener 'load', ->
      jukebox.emit 'SC.ready'

jukebox.on 'SC.ready', ->
  SC.initialize client_id: '7b6445a9fb7d97c3da1310e1b561da79'
  preload = ->
    jukebox.data 'playing.track', ''
    SC.stream '/tracks/115037645',
      (sound) ->
        jukebox.data 'SC.sound', sound
        jukebox.once 'player.mute', ->
          sound.play()
          sound.pause() # this seems to work
          jukebox.emit 'player.ready'
          _.defer ->
            jukebox.once 'player.mute', ->
              jukebox.emit 'player.ready'
              (jukebox.data 'SC.sound').destruct?()
              preload()
  preload()
