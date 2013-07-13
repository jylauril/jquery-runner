meta =
  version: "<%= pkg.version %>"
  name: "<%= pkg.title %>"

runners = {}
_uid = 1

pad = (num) -> (if num < 10 then '0' else '') + num
uid = -> 'runner' + _uid++

_requestAnimationFrame = ((win, raf) ->
  win['webkitR' + raf] or win['r' + raf] or win['mozR' + raf] or win['msR' + raf] or (fn) -> setTimeout(fn, 30)
)(window, 'equestAnimationFrame')

formatTime = (time, settings) ->
  settings = settings or {}
  steps = [3600000, 60000, 1000, 10]
  separator = ['', ':', ':', '.']
  prefix = ''
  output = ''
  ms = settings.milliseconds
  len = steps.length
  value = 0

  if time < 0
    time = Math.abs(time)
    prefix = '-'

  for step, i in steps
    value = 0
    if time >= step
      value = Math.floor(time / step)
      time -= value * step

    if (value or i > 1 or output) and (i isnt len - 1 or ms)
      output += (if output then separator[i] else '') + pad(value)

  prefix + output

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

if @$
  @$.fn.runner = (method, options, start) ->
    if not method
      method = 'init'

    if typeof method is 'object'
      start = options
      options = method
      method = 'init'

    id = @data('runner')
    runner = if id then runners[id] else false
    switch method
      when 'init' then new Runner(@, options, start)
      when 'info' then return runner.info() if runner
      when 'reset' then runner.reset(options) if runner
      when 'lap' then return runner.lap() if runner
      when 'start', 'stop', 'toggle' then return runner[method]() if runner
      when 'version' then return meta.version
      else $.error '[' + meta.name + '] Method ' +  method + ' does not exist'
    return @
  @$.fn.runner.format = formatTime
else
  throw '[' + meta.name + '] jQuery library is required for this plugin to work'
