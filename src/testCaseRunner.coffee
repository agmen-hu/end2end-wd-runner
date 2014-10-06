{Q} = require 'wd'

module.exports = class TestCaseRunner
  constructor: (@_files, @_contextBuilder, @_errorHandler, @_config, @logger) ->
    @_timer = new (require './timer')()

  start: ->
    do @_timer.start
    @_fileIndex = 0;

    @deferred = do Q.defer
    do @_createNewContext
    do @runNextTest

    @deferred.promise

  _createNewContext: ->
    {@_browser, @_context, @_wd} = do @_contextBuilder.buildForNew
    @_errorHandler.init @_config, @logger, @_browser

  runNextTest: =>
    return do @_finish if @_fileIndex >= @_files.length

    do @_createNewContext
    do @_createNextTestCase

    @_context = @_context
      .then @_testCase.runTest
      .fail @_errorHandler.handle
      .then @_tearDown
      .then =>
        @logger.info "TestCase finished in #{do @_timer.getTime} sec"

        return true if not @_errorHandler.errorIsOccured()
        do @_createNewContextOnError
      .then @runNextTest

    return undefined

  _finish: ->
    do @deferred.resolve

  _createNextTestCase: ->
    testFile = @_files[@_fileIndex++]
    @logger.info '\nTestCase: ' + testFile.replace @_config.root, ''

    do @_contextBuilder.setDirty
    do @_errorHandler.resetErrorIsOccurd

    @_testCase = new (require testFile) @_wd, @_browser, @_config, @logger

  _tearDown: =>
    @_testCase
      .runTearDown()
      .fail @_errorHandler.handleTearDown

  _createNewContextOnError: ->
    return false if not @_config.onError.startNewBrowser or @_fileIndex > @_files.length

    {@_browser, @_context, @_wd} = do @_contextBuilder.build
    @_errorHandler.init @_config, @logger, @_browser

