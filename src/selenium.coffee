module.exports =  class Selenium
  constructor: (@runner, @_config) ->
    return do @_createServer if not @_config.wdRemote

    started = true
    do @_setupRunner

  _createServer: ->
    started = false;
    server = (require 'selenium-standalone') stdio: null, @_config.selenium.arguments
    showLog = @_config.selenium.showLog
    server.stderr.on 'data', (output) =>
      console.log do output.toString if showLog

      if not started and output.toString().match /Started.+\.Server/
        started = true
        do @_setupRunner

  _setupRunner: ->
    do @runner
      .setSleepOnError if @_config.browser.browserName isnt 'phantomjs' then @_config.onError.sleep else undefined
      .setTakeScreenShotOnFail @_config.onError.takeScreenShot
      .start

