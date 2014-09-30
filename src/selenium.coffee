module.exports =  class Selenium
  constructor: (@runner, @_config, @logger) ->
    return do @_createServer if not @_config.wdRemote

    started = true
    do @runner.start

  _createServer: ->
    started = false;
    server = (require 'selenium-standalone') stdio: null, @_config.selenium.arguments
    showLog = @_config.selenium.showLog
    server.stderr.on 'data', (output) =>
      @logger.info do output.toString if showLog

      if not started and output.toString().match /Started.+\.Server/
        started = true
        do @runner.start

