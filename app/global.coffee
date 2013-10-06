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
  jukebox.setOnceReturnValue 'once'
  for call in calls
    jukebox.on.apply jukebox, call
  jukebox.data = (name, val) ->
    evt = 'data.' + name
    if val?
      jukebox.removeEvent evt
      jukebox.on evt, (o) ->
        o[name] = val
      jukebox.emit 'changed.' + evt, val
      jukebox.data
    else
      if _.isRegExp name
        evt = new RegExp '^data.' + name.source
      result = {}
      jukebox.emit evt, result
      result[name] ? result

  for k, v of {
    'ws.url': 'ws://10.0.0.69:3343'
  } then jukebox.data k, v
  jukebox.emit 'ready'
)
