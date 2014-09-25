module.exports = class Runner
  constructor: (@_files, @_config) ->

  start: ->
    @_fileIndex = 0;

    do @_createNewContext if not @_config.runner.startTestsWithNewBrowser
    do @runNextTest

  _createNewContext: ->
    do @_browser.quit if @_browser

    @_wd = require 'wd'
    chai = require 'chai'
    chaiAsPromised = require 'chai-as-promised'

    chai.use chaiAsPromised
    do chai.should
    chaiAsPromised.transferPromiseness = @_wd.transferPromiseness

    @_browser = @_wd.promiseChainRemote if @_config.wdRemote then @_config.wdRemote else undefined
    @_context = @_browser.init @_config.browser
    @_errorHandler = new (require './errorHandler') @_browser, @_config

    do @_addCustomAction

  _addCustomAction: ->
    for action in (require 'glob').sync(__dirname+'/action/*')
      new (require action) @_wd, @_browser, @_config

  runNextTest: =>
    return do @finish if @_fileIndex >= @_files.length

    do @_createNewContext if @_config.runner.startTestsWithNewBrowser

    testFile = @_files[@_fileIndex]
    console.log '\nStarted: ' + testFile.replace @_config.root, ''

    @_testCase = new (require testFile) @_wd, @_browser, @_config
    @_context = @_context
      .then @_testCase.runTest
      .then @_tearDown
      .fail @handleError
      .then @runNextTest

    @_fileIndex++

  _tearDown: =>
    @_testCase
      .runTearDown()
      .fail (error) -> console.log "Error from tearDown: #{error}"

  handleError: (error) =>
    @_errorHandler
      .handle error
      .then @_tearDown

  finish: ->
    @_context
      .then => do @_browser.quit
      .done =>
        errorCount = do @_errorHandler.getErrorCount
        console.log '\nFinished' + if errorCount then " with errors count: #{errorCount}" else ''
        process.exit errorCount
