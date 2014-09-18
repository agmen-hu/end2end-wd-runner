module.exports = class Runner
  constructor: (@_files, @_config) ->

  setTakeScreenShotOnFail: (value) ->
    @_takeScreenShotOnFail = value
    return @

  setSleepOnError: (value) ->
    @_sleepOnError = value
    return @

  start: ->
    @_fileIndex = 0;
    @_errorCount = 0;

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

    do @_addCustomAction

  _addCustomAction: ->
    @_wd.addPromiseChainMethod 'runNextTest', @runNextTest

    for action in (require 'glob').sync(__dirname+'/action/*')
      new (require action) @_wd, @_browser, @_config, @errorHandler

  runNextTest: =>
    return do @finish if @_fileIndex >= @_files.length

    do @_createNewContext if @_config.runner.startTestsWithNewBrowser

    testFile = @_files[@_fileIndex]
    console.log 'Started: ' + testFile.replace @_config.root, ''

    @testCase = new (require testFile) @_wd, @_browser, @_config, @errorHandler
    @_context = do @testCase
      .setContext @_context
      .runTest()
      .fail @errorHandler
      .then => do @testCase.tearDown
      .runNextTest

    @_fileIndex++

  finish: ->
    @_context
      .then => do @_browser.quit
      .done => process.exit @_errorCount

  errorHandler: (error) =>
    @_errorCount++

    if @_takeScreenShotOnFail
      @_browser.saveScreenshot().then (fileName) =>
        console.log do error.toString
        console.log "Screenshot from the error: #{fileName}"
        @_browser.sleep @_sleepOnError if @_sleepOnError

    else
      console.log do error.toString
      @_browser.sleep @_sleepOnError if @_sleepOnError
