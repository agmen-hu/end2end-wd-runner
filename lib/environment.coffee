module.exports =  class Envrionment
  constructor: (@runner, @_config) ->
    do @_createServer

  _createServer: ->
    started = false;
    server = (require 'selenium-standalone') stdio: null
    server.stderr.on 'data', (output) =>
      if not started and output.toString().match /Started.+\.Server/
        started = true
        do @_createContext
        do @_setupRunner

  _createContext: ->
    @_wd = require 'wd'
    chai = require 'chai'
    chaiAsPromised = require 'chai-as-promised'

    chai.use chaiAsPromised
    do chai.should
    chaiAsPromised.transferPromiseness = @_wd.transferPromiseness

    @_browser = @_wd.promiseChainRemote if @_config.wdRemote then @_config.wdRemote else undefined
    @_context = @_browser.init @_config.browser

  _setupRunner: ->
    do @runner
      .setWd @_wd
      .setBrowser @_browser
      .setContext @_context
      .setSleepOnError if @_config.browser.browserName isnt 'phantomjs' then @_config.onError.sleep else undefined
      .setTakeScreenShotOnFail if @_config.browser.browserName isnt 'phantomjs' then @_config.onError.takeScreenShot else false
      .start

