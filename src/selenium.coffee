{Q} = require 'wd'

module.exports =  class Selenium
  constructor: (@_config, @logger) ->

  start: ->
    return do @_createServer if not @_config.wdRemote

    @started = true
    do Q

  _createServer: ->
    @_ensureServerIsInstalled()
      .then @_startServer

  _ensureServerIsInstalled: ->
    try
      require 'selenium-standalone'
      do Q
    catch err
      @logger.warn 'Selenium standalone is missing'
      do @_installServer

  _installServer: ->
    @logger.warn "Now will be install here: #{do process.cwd}/node_modules"
    deferred = do Q.defer
    proc = require('child_process').spawn 'npm', ['install', 'selenium-standalone']
    proc.on 'close', (exitCode) ->
      if not exitCode then do deferred.resolve else deferred.reject exitCode

    deferred.promise

  _startServer: =>
    deferred = do Q.defer
    options =
      spawnOptions: { stdio: null }
      seleniumArgs: @_config.selenium.arguments
    (require 'selenium-standalone').start options, (err, child) =>
      showLog = @_config.selenium.showLog
      return deferred.reject err if err
      child.stderr.on 'data', (output) => @_log output if showLog
      @started = true
      do deferred.resolve

    deferred.promise

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
