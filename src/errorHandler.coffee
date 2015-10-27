module.exports = class ErrorHandler
  constructor: ->
    @_errorCount = 0;
    @_browserLogCollector = new (require './browserLogCollector')()

  init: (config, logger, browser) ->
    @logger = logger
    @_config = config
    @_browser = browser
    @_browserLogCollector.setLogger @logger

  resetErrorIsOccurd: -> @_errorIsOccured = false

  errorIsOccured: -> @_errorIsOccured

  getErrorCount: -> @_errorCount

  handle: (error) =>
    if @_config.onError.takeScreenShot
      @_browser.saveScreenshot().then (fileName) =>
        @logger.error error.stack
        @logger.error "Screenshot from the error: #{fileName}"
        do @_handleError

    else
      @logger.error error.stack
      do @_handleError

  _handleError: (error) ->
    @_errorCount++
    @_errorIsOccured = true

    context = if @_config.onError.collectLogsFromBrowser then @_browserLogCollector.collect @_browser else do @_browser.noop
    context = if @_config.onError.sleep then context.sleep @_config.onError.sleep else context

    return context if @_config.onError.sleep or not @_config.onError.pause

    do context.pause

  handleTearDown: (error) =>
    @logger.error "Error from tearDown: #{error}"
    do @_handleError
