require 'colors'

module.exports = class Logger
  levels:
    'log' : 100
    'info' : 200
    'warn' : 300
    'error': 400

  colors:
    log: 'blue'
    info: 'white'
    warn: 'yellow'
    error: 'red'

  constructor: (@_config) ->

  log: (level, message, object) ->
    return false if @levels[level] < @levels[@_config.level]
    if object
      console[level] message[@colors[level]], JSON.stringify(object)[@colors[level]]
    else
      console[level] message[@colors[level]]

  debug: (message, object) ->
    @log 'log', message, object

  info: (message, object) ->
    @log 'info', message, object

  warn: (message, object) ->
    @log 'warn', message, object

  error: (message, object) ->
    @log 'error', message, object
