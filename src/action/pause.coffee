module.exports = class Pause extends (require '../../main').Action
  constructor: (wd, @_browser, @_config, @logger) ->
    super(wd, @_browser, @_config, @logger)

    @readLine = require '../readLine'

  pauseAction: (context) ->
    context
      .chain()
      .then =>
        do @readLine.pauseUntilAnyKey
