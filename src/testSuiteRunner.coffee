module.exports = class TestSuiteRunner
  constructor: (@_config, @logger) ->
    @_timer = new (require './timer')()
    @_fileFinder = new (require './fileFinder')()
    @_configParser = new (require './configParser')()
    @_errorHandler = new (require './errorHandler')()
    @_loggerFactory = new (require './loggerFactory')()
    @_contextBuilder = new (require './contextBuilder') @_config

  start: ->
    do @_timer.start
    @_testSuiteIndex = 0
    @_testSuiteNames = []

    if not @_config.testSuites
      return @_createTestCaseRunner(@_config).start().then @_finish

    @_testSuites = @_config.testSuites
    delete @_config.testSuites

    @_testSuiteNames = Object.keys @_testSuites

    do @runNextTestSuite

  _createTestCaseRunner: (config)->
    @logger = @_loggerFactory.createFrom config
    @_fileFinder.init config, @logger
    @_contextBuilder.init config, @logger

    new (require './testCaseRunner') do @_fileFinder.findTestFiles, @_contextBuilder, @_errorHandler, config, @logger

  _finish: =>
    {_browser} = do @_contextBuilder.getData
    _browser
      .chain()
      .then -> _browser.quit().catch ->
      .done =>
        errorCount = do @_errorHandler.getErrorCount
        @logger.log(
          if errorCount then 'error' else 'info',
          "\nFinished in #{do @_timer.getOverall} sec" + if errorCount then " with error count: #{errorCount}" else '')
        process.exit errorCount

  runNextTestSuite: =>
    return do @_finish if @_testSuiteIndex >= @_testSuiteNames.length

    testSuiteName = @_testSuiteNames[@_testSuiteIndex++]
    testSuiteConfig = @_testSuites[testSuiteName]
    testSuite = @_createTestSuite testSuiteName, testSuiteConfig

    @logger.info "\nTestSuite: #{testSuiteName}"

    testSuite
      .start()
      .then =>
        @logger.info "TestSuite finished in #{do @_timer.getTime} sec"
        do @runNextTestSuite

  _createTestSuite: (name, suiteConfig) ->
    if suiteConfig
      config = @_getConfigFromInclude suiteConfig
      config = @_configParser.merge @_config, config

      if suiteConfig.override
        config = @_configParser.merge config, suiteConfig.override
        config.root = @_getRootFor config
    else
      config = @_config

    @_createTestCaseRunner config

  _getConfigFromInclude: (suiteConfig) ->
    return {} if not suiteConfig.include

    root = @_getRootFor suiteConfig
    return @_configParser.load "#{root}/#{suiteConfig.include}" if typeof suiteConfig.include is 'string'

    config = {}
    include = suiteConfig.include
    config = @_configParser.load "#{root}/#{path}", config for path in include
    return config

  _getRootFor: (suiteConfig) ->
    return @_config.root if not suiteConfig.override or not suiteConfig.override.root
    return (require 'path').relative @_config.root, suiteConfig.override.root
