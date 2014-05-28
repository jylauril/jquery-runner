# Expose the runner as jQuery method
_$.fn.runner = (method, options, start) ->
  if not method
    method = 'init'

  # Normalize params
  if typeof method is 'object'
    start = options
    options = method
    method = 'init'

  # Check if runner is already defined for this element
  id = @data('runner')
  runner = if id then runners[id] else false

  switch method
    when 'init' then new Runner(@, options, start)
    when 'info' then return runner.info() if runner
    when 'reset' then runner.reset(options) if runner
    when 'lap' then return runner.lap() if runner
    when 'start', 'stop', 'toggle' then return runner[method]() if runner
    when 'version' then return meta.version
    else _$.error('[' + meta.name + '] Method ' +  method + ' does not exist')
  return @

# Expose the default format method
_$.fn.runner.format = formatTime
