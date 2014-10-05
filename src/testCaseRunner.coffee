module.exports = class TestCaseRunner
  constructor: (@_files, @_contextBuilder, @_config, @logger) ->
    @_errorHandler = new (require './errorHandler') @_config, @logger
    @_timer = new (require './timer')()

  start: ->
    @_fileIndex = 0;

    do @_timer.start
    do @_createNewContext if not @_config.runner.startTestsWithNewBrowser
    do @runNextTest

  _createNewContext: ->
    {@_browser, @_context, @_wd} = do @_contextBuilder.build
    @_errorHandler.setBrowser @_browser

  runNextTest: =>
    return do @_finish if @_fileIndex >= @_files.length

    do @_createNewContext if @_config.runner.startTestsWithNewBrowser
    do @_createNextTestCase

    @_context = @_context
      .then @_testCase.runTest
      .fail @_errorHandler.handle
      .then @_tearDown
      .then =>
        @logger.info "TestCase finished in #{do @_timer.getTime} sec"

        return true if not @_errorHandler.errorIsOccured()
        do @_createNewContext if @_config.onError.startNewBrowser and @_fileIndex < @_files.length
      .then @runNextTest

    return undefined

  _createNextTestCase: ->
    testFile = @_files[@_fileIndex++]
    @logger.info '\nStarted: ' + testFile.replace @_config.root, ''

    do @_errorHandler.init
    do @_contextBuilder.setDirty

    @_testCase = new (require testFile) @_wd, @_browser, @_config, @logger

  _tearDown: =>
    @_testCase
      .runTearDown()
      .fail @_errorHandler.handleTearDown

  _finish: ->
    @_context
      .then => do @_browser.quit
      .done =>
        errorCount = do @_errorHandler.getErrorCount
        @logger.log(
          if errorCount then 'error' else 'info',
          "\nFinished in #{do @_timer.getOverall} sec" + if errorCount then " with error count: #{errorCount}" else '')
        process.exit errorCount
