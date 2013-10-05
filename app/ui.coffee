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

  updateLayout = ->
    updateChat()
  window.addEventListener 'resize', updateLayout
  updateLayout()

  # chat ui
  $chat = $ 'form.chat-form'
  $chatbox = $ 'form.chat-form input[type=text]'
  $chat.addEventListener 'submit', (e) ->
    sticky = yes # scroll our chat into view
    jukebox.emit 'chat.send', $chatbox.value
    $chatbox.value = ''
    e.preventDefault()

  jukebox.on 'chat.show', (user, message) ->
    jukebox.emit 'template.chat_message', {
      user
      message
    }, (str) ->
      $chatlist.insertAdjacentHTML 'beforeend', str
      updateChatList()

  # login ui
  $login = $ '.account .verb'
  $login.href = '#'
  $modal = $ '.modal'
  $modalRow = $ '.modal .row'
  $loginForm = $ '.modal form'
  $loginBtn = $ '.modal .verb'
  $login.addEventListener 'click', (e) ->
    e.preventDefault()
    jukebox.emit 'login.show'
  $modal.addEventListener 'click', (e) ->
    if e.target is $modal or e.target is $modalRow
      jukebox.emit 'login.hide'
  $loginForm.addEventListener 'submit', (e) ->
    e.preventDefault()
    nickname = ($ 'input[name=nickname]').value
    password = ($ 'input[name=password]').value
    jukebox.emit 'login.perform', nickname, password

  jukebox.on 'login.ping', _.debounce (->
    toggle $loginBtn
    ), 1000, { leading: yes, trailing: yes }

  jukebox.on 'login.show', ->
    $modal.style.visibility = 'visible'
  jukebox.on 'login.hide', ->
    $modal.style.visibility = 'hidden'

  jukebox.on 'login.error.show', (msg) ->
    msg or= 'login failed'
    ($ '.modal .error').innerText = msg
  jukebox.on 'login.error.hide', ->
    ($ '.modal .error').innerText = ''
