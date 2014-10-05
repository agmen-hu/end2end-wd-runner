module.exports = class ErrorHandler
  constructor: (@_config, @logger) ->
    @_errorCount = 0;
    @_browserLogCollector = new (require './browserLogCollector') @logger

  setBrowser: (browser) -> @_browser = browser

  init: -> @_errorIsOccured = false

  errorIsOccured: -> @_errorIsOccured

  getErrorCount: -> @_errorCount

  handle: (error) =>
    if @_config.onError.takeScreenShot
      @_browser.saveScreenshot().then (fileName) =>
        @logger.error do error.toString
        @logger.error "Screenshot from the error: #{fileName}"
        do @_handleError

    else
      @logger.error do error.toString
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
