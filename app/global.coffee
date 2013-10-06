# autoreload settings
window.brunch or= {}
window.brunch.server = '10.0.0.69';

window.$ = HTML.query.bind HTML

((fn) ->
  # todo: verify sanity
  if document.readyState isnt 'loading'
    # wait for the script to load in case we're in an async script
    setTimeout fn, 1
  else
    document.addEventListener 'DOMContentLoaded', fn, no
)(->
  calls = window.jukebox.on._calls or []
  window.jukebox = new EventEmitter
  for call in calls
    jukebox.on.apply jukebox, call
  jukebox.data = (name, val) ->
    evt = 'data.' + name
    if val?
      jukebox.removeEvent evt
      jukebox.on evt, (o) ->
        o.value = val
      jukebox.emit evt + '.changed', val
      jukebox.data
    else
      result = {}
      jukebox.emit evt, result
      result.value ? result

  for k, v of {
    'ws.url': 'ws://10.0.0.69:3343'
  } then jukebox.data k, v
  jukebox.emit 'ready'
)
