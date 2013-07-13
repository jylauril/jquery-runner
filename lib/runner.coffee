class Runner
  constructor: (items, options, start) ->
    return new Runner(items, options, start) unless (@ instanceof Runner)

    @items = items
    id = @id = uid()
    @settings = $.extend({}, @settings, options)

    runners[id] = @
    items.each (index, element) ->
      $(element).data 'runner', id
      return

    @value @settings.startAt
    @start() if start or @settings.autostart

  running: false
  updating: false
  finished: false
  interval: null
  total: 0
  lastTime: 0
  startTime: 0
  lastLap: 0
  lapTime: 0

  settings:
    autostart: false
    countdown: false
    stopAt: null
    startAt: 0
    milliseconds: true
    format: null

  value: (value) ->
    @items.each (item, element) =>
      item = $(element)
      action = if item.is('input') then 'val' else 'text'
      item[action](@format(value))
      return
    return

  format: (value) ->
    format = @settings.format
    format = if $.isFunction(format) then format else formatTime
    format(value, @settings)

  update: ->
    unless @updating
      @updating = true
      settings = @settings
      time = $.now()
      stopAt = settings.stopAt
      countdown = settings.countdown
      delta = time - @lastTime
      @lastTime = time
      if countdown then @total -= delta else @total += delta
      if stopAt isnt null and ((countdown and @total <= stopAt) or (not countdown and @total >= stopAt))
        @total = stopAt
        @finished = true
        @stop()
        @fire 'runnerFinish'

      @value @total
      @updating = false
    return

  fire: (event) ->
    @items.trigger event, @info()
    return

  start: ->
    unless @running
      @running = true
      @reset() if not @startTime or @finished
      @lastTime = $.now()
      step = =>
        if @running
          @update()
          _requestAnimationFrame(step)
        return

      _requestAnimationFrame(step)
      @fire 'runnerStart'
    return

  stop: ->
    if @running
      @running = false
      @update()
      @fire 'runnerStop'
    return

  toggle: ->
    if @running then @stop() else @start()
    return

  lap: ->
    last = @lastTime
    lap = last - @lapTime

    if @settings.countdown
      lap = -lap

    if @running or lap
      @lastLap = lap
      @lapTime = last

    last = @format @lastLap
    @fire 'runnerLap'

    return last

  reset: (stop) ->
    @stop() if stop

    nowTime = $.now()
    if typeof @settings.startAt is 'number' and not @settings.countdown
      nowTime -= @settings.startAt

    @startTime = @lapTime = @lastTime = nowTime
    @total = @settings.startAt
    @value @total
    @finished = false
    @fire 'runnerReset'
    return

  info: ->
    lap = @lastLap or 0
    {
      running: @running
      finished: @finished
      time: @total
      formattedTime: @format(@total)
      startTime: @startTime
      lapTime: lap
      formattedLapTime: @format(lap)
      settings: @settings
    }
