class Runner
    constructor: (items, options, start) ->
        if !(@ instanceof Runner)
          return new Runner(items, options, start)

        @items = items
        $.extend(@settings, options)
        id = @id = uid()
        runners[id] = @
        items.each (index, element) ->
            $(element).data 'runner', id
            return

        @value @settings.startAt

        if start or @settings.autostart
            @start()

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
        interval: 20
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
        if not @updating
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
        if not @running
            @running = true
            if not @startTime or @finished
                @reset()
            @lastTime = $.now()
            @interval = setInterval(=>
                @update()
                return
            , @settings.interval)

            @fire 'runnerStart'
        return

    stop: ->
        if @running
            @running = false
            clearInterval @interval
            @update()
            @fire 'runnerStop'
        return

    toggle: ->
        if @running then @stop() else @start()
        return

    lap: ->
        last = @lastTime
        lap = last - @lapTime
        if @running or lap
            @lastLap = lap
            @lapTime = last
        last = @format @lastLap
        @fire 'runnerLap'
        return last

    reset: (stop) ->
        if stop then @stop()
        @startTime = @lapTime = @lastTime = $.now()
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
