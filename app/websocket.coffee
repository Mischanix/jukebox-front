jukebox.on 'ready', ->
  ws = new WebSocket jukebox.data 'ws.url'
  jukebox.data 'ws.conn', ws
  console.log ws

  jukebox.on 'net.send', (type, data) ->
    if not _.isString type
      throw 'net.send requires a type'
    data or= {}
    data.type = type
    ws.send JSON.stringify data

  ws.addEventListener 'message', (e) ->
    console.log e.data, e
    data = JSON.parse e.data
    type = data.type or 'unknown'
    jukebox.emit 'net.' + type, data
  jukebox.on 'net.ready', ->
    console.log 'net.ready'
