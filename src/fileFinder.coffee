module.exports = class FileFinder
  constructor: (glob) ->
    @_glob = if glob then glob else require 'glob'
    @_coffeeIsRegistred = false

  init: (config, logger) ->
    @_config = config
    @logger = logger

  findTestFiles: ->
    @_testFiles = @_glob.sync @_config.root + '**/*Test.*'

    grepRegexp = @_config.runner.grep
    @_filterTests grepRegexp, 'match'

    excludeRegexp = if grepRegexp then undefined else @_config.runner.exclude
    @_filterTests excludeRegexp

    do @_handleCoffescript if not @_coffeeIsRegistred

    @_testFiles

  _filterTests: (regexp, match = false) ->
    return false if not regexp

    regexp = new RegExp regexp
    @_testFiles = @_testFiles.filter (file) =>
      matched = file.replace(@_config.root, '').match regexp
      (match and matched) or (not match and not matched)

  _handleCoffescript: ->
    try
      require 'coffee-script/register' if @_testFiles.some (file) -> file.match /\.coffee$/
      @_coffeeIsRegistred = true
    catch error
      @_filterTests '\.coffee$'
      @logger.warn 'Coffee tests cannot be executed with coffee-script so these tests are removed from the hit list.'
