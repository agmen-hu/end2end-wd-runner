module.exports = class Runner
  constructor: (@_files, @_config) ->
    @_errorHandler = new (require './errorHandler') @_config

  start: ->
    @_fileIndex = 0;

    do @_createNewContext if not @_config.runner.startTestsWithNewBrowser
    do @runNextTest

  _createNewContext: ->
    return true if @_freshContext

    do @_browser.quit if @_browser

    @_wd = require 'wd'
    chai = require 'chai'
    chaiAsPromised = require 'chai-as-promised'

    chai.use chaiAsPromised
    do chai.should
    chaiAsPromised.transferPromiseness = @_wd.transferPromiseness

    @_browser = @_wd.promiseChainRemote if @_config.wdRemote then @_config.wdRemote else undefined
    @_context = @_browser.init @_config.browser
    @_freshContext = true

    @_errorHandler.setBrowser @_browser

    do @_addCustomAction

  _addCustomAction: ->
    for action in (require 'glob').sync(__dirname+'/action/*')
      new (require action) @_wd, @_browser, @_config

  runNextTest: =>
    return do @_finish if @_fileIndex >= @_files.length

    do @_createNewContext if @_config.runner.startTestsWithNewBrowser
    do @_createNextTestCase

    @_context = @_context
      .then @_testCase.runTest
      .fail @_errorHandler.handle
      .then @_tearDown
      .then =>
        return true if not @_errorHandler.errorIsOccured()
        do @_createNewContext if @_config.onError.startNewBrowser
      .then @runNextTest

    return undefined

  _createNextTestCase: ->
    testFile = @_files[@_fileIndex++]
    console.log '\nStarted: ' + testFile.replace @_config.root, ''

    do @_errorHandler.init
    @_freshContext = false

    @_testCase = new (require testFile) @_wd, @_browser, @_config

  _tearDown: =>
    @_testCase
      .runTearDown()
      .fail @_errorHandler.handleTearDown

  _finish: ->
    @_context
      .then => do @_browser.quit
      .done =>
        errorCount = do @_errorHandler.getErrorCount
        console.log '\nFinished' + if errorCount then " with error count: #{errorCount}" else ''
        process.exit errorCount
