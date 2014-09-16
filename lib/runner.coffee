module.exports = class Runner
  constructor: (@_files, @_config) ->

  setWd: (wd) ->
    wd.addPromiseChainMethod 'runNextTest', @runNextTest
    @_wd = wd
    return @

  runNextTest: =>
    do @testCase.tearDown if @testCase
    return do @finish if @_fileIndex >= @_files.length

    @testCase = new (require @_files[@_fileIndex]) @_wd, @_browser, @_config, @errorHandler
    @_context = do @testCase
      .setContext @_context
      .test()
      .fail @errorHandler
      .runNextTest

    @_fileIndex++

  finish: ->
    @_context
      .then => do @_browser.quit
      .done -> do process.exit

  errorHandler: (error) =>
    if @_takeScreenShotOnFail
      @_browser.saveScreenshot().then (fileName) =>
        console.log do error.toString
        console.log "Screenshot from the error: #{fileName}"
        @_browser.sleep @_sleepOnError if @_sleepOnError

    else
      console.log do error.toString
      @_browser.sleep @_sleepOnError if @_sleepOnError

  setBrowser: (value) ->
    @_browser = value
    return @

  setContext: (value) ->
    @_context = value
    return @

  setTakeScreenShotOnFail: (value) ->
    @_takeScreenShotOnFail = value
    return @

  setSleepOnError: (value) ->
    @_sleepOnError = value
    return @

  start: ->
    @_fileIndex = 0;

    do @addCustomAction
    do @runNextTest

  addCustomAction: ->
    for action in (require 'glob').sync(__dirname+'/action/*')
      new (require action) @_wd, @_browser, @_config, @errorHandler
