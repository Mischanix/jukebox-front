jukebox.on 'connect', ->
  closed = false
  restarting = false
  jukebox.data 'ws.lastAttempt', Date.now()
  ws = new WebSocket jukebox.data 'ws.url'
  jukebox.data 'ws.conn', ws

  jukebox.on 'net.send', (type, data) ->
    if not _.isString type
      throw 'net.send requires a type'
    data or= {}
    if not _.isPlainObject data
      throw 'net.send requires data be a plain object'
    data.type = type
    ws.send JSON.stringify data

  ws.addEventListener 'message', (e) ->
    console.log e.data
    data = JSON.parse e.data
    type = data.type or 'unknown'
    jukebox.emit 'net.' + type, data

  jukebox.once 'net.reconnect', ->
    restarting = true
    ws.close()

  jukebox.once 'net.ready', ->
    if true is jukebox.data 'ws.closed'
      jukebox.emit 'notification', 'you were reconnected to the server'
      jukebox.data 'ws.closed', false

    ws.addEventListener 'close', (e) ->
      jukebox.removeEvent 'net.send'
      if not restarting
        console.log 'websocket closed'
        jukebox.data 'ws.closed', true
        jukebox.emit 'notification', 'you were disconnected from the server'
      else
        restarting = false
      delay = 100 # ms
      if Date.now() - jukebox.data 'ws.lastAttempt' > 20*1000
        jukebox.data 'ws.delay', 100
      else
        delay = jukebox.data 'ws.delay'
        jukebox.data 'ws.delay', Math.min(delay * 2, 4*1000)
      _.delay (->
        jukebox.emit 'connect'), delay
    console.log 'net.ready'

jukebox.on 'ready', ->
  jukebox.data 'ws.delay', 100 # ms
  jukebox.emit 'connect'
