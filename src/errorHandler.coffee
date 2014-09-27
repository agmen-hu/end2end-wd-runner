module.exports = class ErrorHandler
  constructor: (@_config) ->
    @_errorCount = 0;

  setBrowser: (browser) -> @_browser = browser

  init: -> @_errorIsOccured = false

  errorIsOccured: -> @_errorIsOccured

  getErrorCount: -> @_errorCount

  handle: (error) =>
    if @_config.onError.takeScreenShot
      @_browser.saveScreenshot().then (fileName) =>
        console.log do error.toString
        console.log "Screenshot from the error: #{fileName}"
        do @_handleError

    else
      console.log do error.toString
      do @_handleError

  _handleError: (error) ->
    @_errorCount++
    @_errorIsOccured = true

    return @_browser.sleep @_config.onError.sleep if @_config.onError.sleep

  handleTearDown: (error) =>
    console.log "Error from tearDown: #{error}"
    do @_handleError
