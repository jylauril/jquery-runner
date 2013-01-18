pad = (num) -> (if num < 10 then '0' else '') + num
runners = {}
_uid = 1
uid = () -> 'runner' + _uid++
formatTime = (time, settings) ->
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
        if time >= step
            value = Math.floor(time / step)
            time -= value * step

        if (value or i > 1 or output) and (i isnt len - 1 or ms)
            output += (if output then separator[i] else '') + pad(value)

    prefix + output
