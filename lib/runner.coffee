# ## The Runner class

class Runner
  constructor: (items, options, start) ->
    # Allow runner to be called as a function by returning an instance
    return new Runner(items, options, start) unless (@ instanceof Runner)

    @items = items
    id = @id = uid()
    @settings = _$.extend({}, @settings, options)

    # Store reference to this instance
    runners[id] = @
    items.each((index, element) ->
      # Also save reference to each element
      _$(element).data('runner', id)
      return
    )

    # Set initial value
    @value(@settings.startAt)
    # Start the runner if `autostart` is defined
    @start() if start or @settings.autostart

  # Runtime states for the runner instance
  running: false
  updating: false
  finished: false
  interval: null

  # Place to store times during runtime
  total: 0
  lastTime: 0
  startTime: 0
  lastLap: 0
  lapTime: 0

  # Settings for the runner instance
  settings: {
    autostart: false
    countdown: false
    stopAt: null
    startAt: 0
    milliseconds: true
    format: null
  }

  # Method to update current time value to runner's elements
  value: (value) ->
    @items.each((item, element) =>
      item = _$(element)
      # If the element is an input, we need to use `val` instead of `text`
      action = if item.is('input') then 'val' else 'text'
      item[action](@format(value))
      return
    )
    return

  # Method that handles the formatting of the current time to a string
  format: (value) ->
    format = @settings.format
    # If custom format method is defined, use it, otherwise use the default formatter
    format = if _$.isFunction(format) then format else formatTime
    format(value, @settings)

  # Method to update runner cycle
  update: ->
    # Make sure we are not already updating the cycle
    unless @updating
      @updating = true
      settings = @settings
      time = _$.now()
      stopAt = settings.stopAt
      countdown = settings.countdown
      delta = time - @lastTime
      @lastTime = time
      # Check if we are counting up or down and update delta accordingly
      if countdown then @total -= delta else @total += delta
      # If `stopAt` is defined and we have reached the end, finish the cycle
      if stopAt isnt null and ((countdown and @total <= stopAt) or (not countdown and @total >= stopAt))
        @total = stopAt
        @finished = true
        @stop()
        @fire('runnerFinish')

      # Update current value
      @value(@total)
      @updating = false
    return

  # Method to fire runner events to the element
  fire: (event) ->
    @items.trigger(event, @info())
    return

  # Method to start the runner
  start: ->
    # Make sure we're not already running
    unless @running
      @running = true
      # Reset the current time value if we were not paused
      @reset() if not @startTime or @finished
      @lastTime = _$.now()
      step = =>
        if @running
          # Update cycle if we are still running
          @update()
          # Request a new update cycle
          _requestAnimationFrame(step)
        return

      _requestAnimationFrame(step)
      @fire('runnerStart')
    return

  # Method to stop the runner
  stop: ->
    # Make sure we're actually running
    if @running
      @running = false
      @update()
      @fire('runnerStop')
    return

  # Method to toggle current runner state
  toggle: ->
    if @running then @stop() else @start()
    return

  # Method to request the current lap time
  lap: ->
    last = @lastTime
    lap = last - @lapTime

    if @settings.countdown
      lap = -lap

    if @running or lap
      @lastLap = lap
      @lapTime = last

    last = @format(@lastLap)
    @fire('runnerLap')

    return last

  # Method to reset the runner to original state
  reset: (stop) ->
    # If we passed in a boolean true, stop the runner
    @stop() if stop

    nowTime = _$.now()
    if typeof @settings.startAt is 'number' and not @settings.countdown
      nowTime -= @settings.startAt

    @startTime = @lapTime = @lastTime = nowTime
    @total = @settings.startAt
    # Update runner value back to original state
    @value(@total)
    @finished = false
    @fire('runnerReset')
    return

  # Method to return the current runner state
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
