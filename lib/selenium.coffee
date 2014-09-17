module.exports =  class Envrionment
  constructor: (@runner, @_config) ->
    return do @_createServer if not @_config.wdRemote

    started = true
    do @_setupRunner

  _createServer: ->
    started = false;
    server = (require 'selenium-standalone') stdio: null
    server.stderr.on 'data', (output) =>
      if not started and output.toString().match /Started.+\.Server/
        started = true
        do @_setupRunner

  _setupRunner: ->
    do @runner
      .setSleepOnError if @_config.browser.browserName isnt 'phantomjs' then @_config.onError.sleep else undefined
      .setTakeScreenShotOnFail if @_config.browser.browserName isnt 'phantomjs' then @_config.onError.takeScreenShot else false
      .start

