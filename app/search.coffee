jukebox.on 'SC.ready', ->
  page_size = 20 # latency!
  jukebox.on 'search', (query, page, cb) ->
    if page < 0
      cb null
    else
      SC.get '/tracks',
        q: query
        limit: page_size
        offset: page * page_size,
        (results) ->
          if not (_.isArray results) or results.length is 0
            cb null
          else
            cb results
