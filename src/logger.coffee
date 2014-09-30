module.exports = class Logger
  levels:
    'debug' : 100
    'info' : 200
    'warning' : 300
    'warn' : 300
    'error': 400
    'err': 400

  constructor: (@_config) ->

  log: (level, message, object) ->
    return false if @levels[level] < @levels[@_config.level]
    if object
      console[level] message, JSON.stringify object
    else
      console[level] message

  debug: (message, object) ->
    @log 'debug', message, object

  info: (message, object) ->
    @log 'info', message, object

  warn: (message, object) ->
    @log 'warn', message, object

  error: (message, object) ->
    @log 'error', message, object
