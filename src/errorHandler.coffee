module.exports = class ErrorHandler
  constructor: (@_config) ->
    @_errorCount = 0;

  setBrowser: (browser) ->
    @_browser = browser
    return @

  getErrorCount: -> @_errorCount

  handle: (error) =>
    @_errorCount++

    if @_config.onError.takeScreenShot
      @_browser.saveScreenshot().then (fileName) =>
        console.log "Screenshot from the error: #{fileName}"
        @_handleError error

    else
      @_handleError error

  _handleError: (error) ->
    console.log do error.toString
    @_browser.sleep @_config.onError.sleep if @_config.onError.sleep

    do @_browser.chain
