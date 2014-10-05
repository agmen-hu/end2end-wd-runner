module.exports = class FileFinder
  constructor: ->
    @coffeeIsRegistred = false

  setConfig: (config) ->
    @config = config

  setLogger: (logger) ->
    @logger = logger

  findTestFiles: ->
    @_testFiles = (require 'glob').sync @config.root + '**/*Test.*'

    grepRegexp = @config.runner.grep
    @_filterTests grepRegexp, 'match'

    excludeRegexp = if grepRegexp then undefined else @config.runner.exclude
    @_filterTests excludeRegexp

    do @_handleCoffescript if not @coffeeIsRegistred

    @_testFiles

  _filterTests: (regexp, match = false) ->
    return false if not regexp

    regexp = new RegExp regexp
    @_testFiles = @_testFiles.filter (file) =>
      matched = file.replace(@config.root, '').match regexp
      (match and matched) or (not match and not matched)

  _handleCoffescript: ->
    try
      require 'coffee-script/register' if @_testFiles.some (file) -> file.match /\.coffee$/
      @coffeeIsRegistred = true
    catch error
      @_filterTests '\.coffee$'
      @logger.warn 'Coffee tests cannot be executed with coffee-script so these tests are removed from the hit list.'
