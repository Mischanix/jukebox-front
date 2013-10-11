jukebox.on 'ready', ->
  console.log 'meow'

  # helpers
  emToPx = (em, el) ->
    el or= document.body
    em * parseFloat (computedStyle el, 'font-size'), 10

  toggle = (el) ->
    if el.classList.contains 'toggle'
      el.classList.remove 'toggle'
    else
      el.classList.add 'toggle'

  # layout stuff
  $chatlist = $ '.chat .list'
  $inputrow = $ '.chat .row:last-of-type'
  chatlistHeight = -> parseFloat (computedStyle $chatlist, 'height'), 10
  updateChat = ->
    # make the bottom of the chat follow the bottom of the viewport
    inputBounds = $inputrow.getBoundingClientRect()
    halfEm = emToPx 0.5, $chatlist
    targetBottom = window.innerHeight - inputBounds.height - halfEm
    chatlistBounds = $chatlist.getBoundingClientRect()
    deltaHeight = targetBottom - chatlistBounds.bottom
    targetHeight = chatlistHeight() + deltaHeight
    if targetHeight > 0
      $chatlist.style.height = targetHeight + 'px'
    updateChatList()

  sticky = yes
  $chatlist.addEventListener 'scroll', _.debounce (->
    halfEm = emToPx 0.5, $chatlist
    sticky = $chatlist.scrollTop + chatlistHeight() + halfEm >
      $chatlist.scrollHeight
    ), 100

  $spacer = $ '.chat .spacer'
  updateChatList = ->
    scrollHeightPre = $chatlist.scrollHeight
    _chatlistHeight = chatlistHeight()
    # update the spacer that keeps new chats in an empty chat frame at the
    # bottom to be the proper height
    # Since scrollHeight is min(height of element, height of children), if we
    # want to calculate our desired spacer height based on scrollHeight, we
    # need to make the height of the children >= the height of the element,
    # and we need to make the height of the children independent of the
    # spacer's height.
    # But first, be sure it's possible for the spacer to be visible:
    if scrollHeightPre <= 2 * _chatlistHeight
      $spacer.style.height = '100%'
      spacerHeight = 2 * _chatlistHeight - $chatlist.scrollHeight
      if spacerHeight > 0
        $spacer.style.height = spacerHeight + 'px'
      else
        $spacer.style.height = '0'
    # defer because mobile safari idk
    _.defer ->
      until $chatlist.children.length < 100
        $chatlist.children[1].remove()
      _.defer ->
        # scroll the chat list to the bottom or maintain the current scroll
        # height relative to the bottom depending on the value of `sticky`
        if sticky
          $chatlist.scrollTop = $chatlist.scrollHeight - _chatlistHeight
        else
          $chatlist.scrollTop += $chatlist.scrollHeight - scrollHeightPre
    null

  # a copy of updateChat, minus the def/val diff for *listHeight and the
  # spacing at the bottom
  $searchlist = $ '.search .list'
  updateSearch = ->
    # adjust the height of the search results list
    targetBottom = window.innerHeight
    searchlistBounds = $searchlist.getBoundingClientRect()
    deltaHeight = targetBottom - searchlistBounds.bottom
    targetHeight = deltaHeight +
      parseFloat (computedStyle $searchlist, 'height'), 10
    if targetHeight > 0 # beware: value can be NaN
      $searchlist.style.height = targetHeight + 'px'

  updateLayout = ->
    updateChat()
    updateSearch()
  window.addEventListener 'resize', updateLayout
  updateLayout()

  # margin 0 auto messes up when going from landscape to portrait on iOS.
  # this is a suitable workaround
  window.addEventListener 'orientationchange', (e) ->
    ($ '.row').each (row) ->
      row.classList.add 'ios-fix'
      _.defer -> row.classList.remove 'ios-fix'

  # chat ui
  $chat = $ 'form.chat-form'
  $chatbox = $ 'form.chat-form input[type=text]'
  $chat.addEventListener 'submit', (e) ->
    sticky = yes # scroll our chat into view
    jukebox.emit 'chat.send', $chatbox.value
    $chatbox.value = ''
    e.preventDefault()

  jukebox.on 'chat.show', (user, message, notification) ->
    jukebox.emit 'template.chat_message', {
      user
      message
      notification
    }, (str) ->
      $chatlist.insertAdjacentHTML 'beforeend', str
      updateChatList()

  # login ui
  $login = $ '.account .verb'
  $login.href = '#'
  $loginModal = $ '.modal.login'
  $loginModalRow = $ '.modal.login .row'
  $loginForm = $ '.modal.login form'
  $loginBtn = $ '.modal.login .verb'
  $login.addEventListener 'click', (e) ->
    e.preventDefault()
    if true is jukebox.data 'user.fake'
      jukebox.emit 'login.show'
    else
      jukebox.emit 'logout'
  $loginModal.addEventListener 'click', (e) ->
    if e.target is $loginModal or e.target is $loginModalRow
      jukebox.emit 'login.hide'
  $loginForm.addEventListener 'submit', (e) ->
    e.preventDefault()
    nickname = ($ 'input[name=nickname]').value
    password = ($ 'input[name=password]').value
    jukebox.emit 'login', nickname, password

  jukebox.on 'login.ping', _.debounce (->
    toggle $loginBtn
    ), 1000, { leading: yes, trailing: yes }

  jukebox.on 'login.show', ->
    $loginModal.style.display = 'block'
  jukebox.on 'login.hide', ->
    $loginModal.style.display = 'none'

  jukebox.on 'login.error.show', (msg) ->
    msg or= 'login failed'
    ($ '.modal.login .error').innerText = msg
  jukebox.on 'login.error.hide', ->
    ($ '.modal.login .error').innerText = ''

  # account info ui
  $quarters = $ '.quarters'
  quartersNomized = (val) ->
    val = val.toString 10
    val = 'no' if val is '0'
    nominal = do ->
      if val.length < 5
        if val is '1'
          'quarter'
        else
          'quarters'
      else
        'q'
    val + ' ' + nominal
  jukebox.on 'changed.data.user.quarters', (val) ->
    $quarters.innerText = quartersNomized val

  jukebox.on 'changed.data.user.fake', (val) ->
    if val is true
      $login.innerText = 'login / register'
    if val is false
      $login.innerText = 'logout'

  jukebox.on 'changed.data.user.nick', (nick) ->
    $chatbox.placeholder = nick + ':'

  # playback ui
  $progress = $ '.progress'
  $indicator = $ '.indicator'
  $elapsed = $ 'p.elapsed'
  $total = $ 'p.total'
  padLeft = (str, len) ->
    if str.length < len
      padLeft '0' + str, len
    else
      str
  formatTime = (milliseconds) ->
    seconds = Math.round milliseconds / 1000
    minutes = Math.floor seconds / 60
    seconds = seconds % 60
    return (minutes.toString 10) + '.' + padLeft (seconds.toString 10), 2
  _pos = -1
  _dur = -1
  lastPos = 0
  stopLastAnimation = -> null
  jukebox.on 'playback.progress', (pos, dur) ->
    if _pos isnt Math.round pos / 1000
      $elapsed.innerText = formatTime pos
      _pos = Math.round pos / 1000
    if _dur isnt dur
      $total.innerText = formatTime dur
      _dur = dur
    # progress bar
    if pos > lastPos
      interval = pos - lastPos
      stopLastAnimation()
      do ->
        startTime = Date.now()
        animating = true
        stopLastAnimation = -> animating = false
        _.delay stopLastAnimation, interval
        $progressWidth = parseFloat (computedStyle $progress, 'width'), 10
        lastWidth = Math.floor 4 * $progressWidth * pos / dur
        frame = ->
          interpPos = Date.now() - startTime + pos
          currWidth = Math.floor 4 * $progressWidth * interpPos / dur
          if currWidth isnt lastWidth
            lastWidth = currWidth
            percent = ((100 * interpPos / dur).toString 10) + '%'
            $indicator.style.width = percent
          requestAnimationFrame frame if animating
          null
        frame()
    if pos is dur
      lastPos = -1
    else
      lastPos = pos

  # search ui
  $modalSearch = $ '.modal.search'
  showSearch = ->
    $modalSearch.style.display = 'block'
    $searchLoading.innerText = ''
    updateSearch()
  hideSearch = ->
    $modalSearch.style.display = 'none'
    jukebox.data 'search.query', ''
  $queueVerb = $ '.queue.verb'
  $queueVerb.style.cursor = 'pointer'
  $queueVerb.addEventListener 'click', (e) ->
    e.preventDefault()
    showSearch()
  $modalSearch.addEventListener 'click', (e) ->
    if e.target is $modalSearch
      e.preventDefault()
      hideSearch()
  $searchCancel = $ '.modal.search .verb.cancel'
  $searchCancel.addEventListener 'click', (e) ->
    e.preventDefault()
    hideSearch()

  $searchInput = $ 'input[name=search]'
  $searchInput.addEventListener 'keyup', _.debounce (->
    jukebox.data 'search.query', $searchInput.value
  ), 1000/3.5
  jukebox.data 'search.query', ''

  # search results list ui
  $searchLoading = $ '.modal.search .loading'
  jukebox.on 'changed.data.search.query', (query) ->
    resetSearch()
    if $searchInput.value isnt query
      $searchInput.value = query
    return if query is ''

    pagesShown = []
    pagesRequested = []
    jukebox.on 'search.page', (page) ->
      $searchLoading.style.display = 'block'
      $searchLoading.innerText = 'loading...'
      jukebox.emit 'search', query, page, (results) ->
        if results is null
          $searchLoading.innerText = 'no more results'
          jukebox.removeEvent 'search.page.next'
        else
          $searchLoading.style.display = 'none'
          allResults = jukebox.data 'search.results'
          allResults[page] = results
          jukebox.emit 'changed.data.search.results', allResults

    jukebox.on 'changed.data.search.results', (results) ->
      _.each results, (pageList, pageNum) ->
        if pageList? and not pagesShown[pageNum] and shouldShowPage pageNum
          beforeEl = _($ '.modal.search .song').foldr ((a, el) ->
            if pageNum < parseInt el.dataset.page, 10 then el else a
          ), null
          if beforeEl is null
            beforeEl = $searchLoading
          _(pageList).map (o) ->
            id: o.id
            page: pageNum
            link: o.permalink_url
            artist: o.user.username
            title: o.title
            duration: formatTime o.duration
            cost: do ->
              val = queueCost o.duration
              if _.isFinite val
                quartersNomized val
              else
                'too long'
            queueable: _.isFinite queueCost o.duration
          .each (song) ->
            jukebox.emit 'template.search_result', song, (str) ->
              beforeEl.insertAdjacentHTML 'beforebegin', str
              bindHandlers beforeEl.previousElementSibling
          pagesShown[pageNum] = true
      updateScrollbreak()

    bindHandlers = (el) ->
      $el = HTML.ify el
      $enqueueButton = $el.query '.verb.enqueue'
      if not _.isArray $enqueueButton
        $el.addEventListener 'click', (e) ->
          if e.target isnt $enqueueButton
            e.preventDefault()
            _.defer -> window.open $el.dataset.link, 'jukeboxPreview'
        $enqueueButton.addEventListener 'click', ->
          jukebox.emit 'enqueue', $el.dataset.id
          hideSearch()


    shouldShowPage = (pageNum) -> _.contains pagesRequested, pageNum
    requestPage = (pageNum) ->
      pagesRequested.push pageNum
      if not (jukebox.data 'search.results')[pageNum]?
        jukebox.once 'search.page.next', ->
          requestPage pageNum + 1
        jukebox.emit 'search.page', pageNum

    requestPage 0

  resetSearch = ->
    jukebox.removeEvent 'changed.data.search.results'
    jukebox.data 'search.results', []
    ($ '.modal.search .song').each (el) -> el.remove()
    jukebox.removeEvent 'search.page'
    jukebox.removeEvent 'search.page.next'

  $searchlist.addEventListener 'scroll', (e) ->
    if $searchlist.scrollTop > jukebox.data 'search.scrollbreak'
      jukebox.emit 'search.page.next'
  updateScrollbreak = ->
    allSongs = ($ '.modal.search .song')
    if allSongs.length > 10
      breakEl = allSongs[allSongs.length - 10]
      scrollbreak = breakEl.getBoundingClientRect().top -
        allSongs[0].getBoundingClientRect().top
      jukebox.data 'search.scrollbreak', scrollbreak
    else
      jukebox.data 'search.scrollbreak', 1/0


  queueCost = (duration) -> # milliseconds
    if duration < 7.5*60*1000
      1
    else if duration < 15*60*1000
      3
    else
      1/0
