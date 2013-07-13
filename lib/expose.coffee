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
