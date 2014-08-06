# ## Helper methods

# Meta object that gets prepopulated with version info, etc.
meta = {
  version: "<%= pkg.version %>"
  name: "<%= pkg.title %>"
}

_$ = @jQuery or @Zepto or @$

unless _$ and _$.fn
  # Require jQuery or any other jQuery-like library
  throw new Error('[' + meta.name + '] jQuery or jQuery-like library is required for this plugin to work')

# A place to store the runners
runners = {}

# Pad numbers so they are always two characters
pad = (num) -> (if num < 10 then '0' else '') + num

_uid = 1
# Helper method to generate a unique identifier
uid = -> 'runner' + _uid++

# Resolve a browser specific method for `requestAnimationFrame`
_requestAnimationFrame = ((win, raf) ->
  win['r' + raf] or win['webkitR' + raf] or win['mozR' + raf] or win['msR' + raf] or (fn) -> setTimeout(fn, 30)
)(@, 'equestAnimationFrame')

# Helper method to generate a time string from a timestamp
formatTime = (time, settings) ->
  settings = settings or {}
  # Steps: hours, minutes, seconds, milliseconds
  steps = [3600000, 60000, 1000, 10]
  separator = ['', ':', ':', '.']
  prefix = ''
  output = ''
  ms = settings.milliseconds
  len = steps.length
  value = 0

  # Check if we are in negative values and mark the prefix
  if time < 0
    time = Math.abs(time)
    prefix = '-'

  # Go through the steps and generate time string
  for step, i in steps
    value = 0
    # Check if we have enough time left for the next step
    if time >= step
      value = Math.floor(time / step)
      time -= value * step

    if (value or i > 1 or output) and (i isnt len - 1 or ms)
      output += (if output then separator[i] else '') + pad(value)

  prefix + output
