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
      @_log output if showLog

      if not started and output.toString().match /Started.+\.Server/
        started = true
        do @runner.start

  _log: (buffer) ->
    line = do buffer.toString
    line = do line.trim
    level = line.match /[\d:.\s]{13}(\w+)/

    return @logger.info "Selenium: #{line}" if not level

    level = do level[1].toLowerCase
    level = if level is 'warning' then 'warn' else level
    level = if @logger[level] then level else 'info'
    line = line.replace /[\d:.\s]{13}\w+\s-\s(.+)/, '$1'

    @logger[level] "Selenium: #{line}"

