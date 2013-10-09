do ->
  sm2 = undefined
  Object.defineProperty window, 'soundManager',
    get: -> sm2
    set: (val) ->
      sm2 = val
      if sm2?
        bDI = sm2.beginDelayedInit
        sm2.beginDelayedInit = ->
          sm2.preferFlash = false
          sm2.useHTML5Audio = true
          bDI.apply sm2, arguments
