{Q} = require 'wd'

module.exports = class TestCaseRunner
  constructor: (@_files, @_contextBuilder, @_errorHandler, @_config, @logger, @_isLast) ->
    @_timer = new (require './timer')()

  start: ->
    do @_timer.start
    @_fileIndex = 0;

    @deferred = do Q.defer
    do @_setContextData
    do @runNextTest

    @deferred.promise

  _setContextData: ->
    {@_browser, @_context, @_wd} = do @_contextBuilder.getData
    @_errorHandler.init @_config, @logger, @_browser

  runNextTest: =>
    return do @_finish if @_fileIndex >= @_files.length

    do @_createNewContext if @_config.runner.startTestsWithNewBrowser
    do @_createNextTestCase

    @_context = @_context
      .then @_testCase.runTest
      .catch @_errorHandler.handle
      .then @_tearDown
      .then =>
        @logger.info "TestCase finished in #{do @_timer.getTime} sec"

        return true if not @_errorHandler.errorIsOccured()
        do @_createNewContextOnError
      .then @runNextTest

    return undefined

  _finish: ->
    do @deferred.resolve

  _createNewContext: ->
    do @_contextBuilder.build
    do @_setContextData

  _createNextTestCase: ->
    testFile = @_files[@_fileIndex++]
    @logger.info '\nTestCase: ' + testFile.replace @_config.root, ''

    do @_contextBuilder.markAsDirty
    do @_errorHandler.resetErrorIsOccurd

    @_testCase = new (require testFile)
      wd: @_wd
      browser: @_browser
      config: @_config
      logger: @logger

  _tearDown: =>
    @_testCase
      .runTearDown()
      .catch @_errorHandler.handleTearDown

  _createNewContextOnError: ->
    return false if not @_config.onError.startNewBrowser or @_fileIndex is @_files.length

    do @_createNewContext
