class MPDPlayer
  audio: null
  websocket: null
  expectedState: null
  playbackStates: ['play', 'stop', 'pause']

  constructor: ->
    @openWebSocket()
    @bindEvents()

  openWebSocket: ->
    url = location.href.replace(/^http/, 'ws')
    @websocket = new WebSocket(url)
    @websocket.onopen = @onWebSocketOpen
    @websocket.onclose = @onWebSocketClose
    @websocket.onmessage = @onWebSocketMessage

  bindEvents: ->
    $('menu button').on('click', @onButtonClick)

  onWebSocketOpen: =>
    @requestInterval = setInterval(@sendWebsocketMessage, 3000)

  onWebSocketClose: =>
    clearInterval(@requestInterval)

  onWebSocketMessage: (message) =>
    data = JSON.parse(message.data)
    if data? && data.state?
      @hideSpinner() if @expectedState? && data.state == @expectedState
      @displayInformation(data)
      this[data.state]() if data.state in @playbackStates

  onButtonClick: (event) =>
    buttonAction = $(event.currentTarget).data('action')
    @sendWebsocketMessage(buttonAction)
    @expectedState = buttonAction
    @showSpinner()

  sendWebsocketMessage: (message = 'status') =>
    @websocket.send(message)

  initializeAudio: ->
    @audio = $('<audio>').prop('src', streamURL).appendTo('body')[0]

  removeAudio: ->
    $(@audio).remove()
    @audio = null

  play: ->
    @initializeAudio() unless @audio?
    @audio.play()
    @switchPlayPauseState('pause')

  stop: ->
    @removeAudio() if @audio?
    @switchPlayPauseState('play')

  pause: ->
    @switchPlayPauseState('play')

  switchPlayPauseState: (state) ->
    $('button#playstop').removeClass('play pause').addClass(state).data('action', state)

  displayInformation: (data) ->
    if data.song_title? && data.song_artist?
      current_song = "#{data.song_title} - #{data.song_artist}"
      state = if data.state == 'pause' then '(paused)' else '(playing)'
    else
      current_song = ''
      state = ''
    $('#current-song').html("<h3>#{current_song}</h3>")
    $('#state').text(state)

  showSpinner: ->
    $('#spin').spin('small')

  hideSpinner: ->
    $('#spin').spin(false)

$ -> new MPDPlayer()
