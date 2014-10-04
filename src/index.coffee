module.exports = class Index
  program: require 'commander'

  start: ->
    do @processsArgv
    do @findRoot
    do @loadConfig
    do @extendConfig
    do @createLogger
    do @findTestFiles
    do @createRunner

  processsArgv: ->
    @program
      .option '-c --config <path>', 'path to config yml. Default is root/config.yml'
      .option '-b --browser <firefox|chrome|phantomjs>', 'Default is come from the config'
      .option '-r --root <directory>', 'root directory for text search. Default is end2endTests'
      .option '-g --grep <pattern>', 'regexp matcher for wich tests being executed'
      .option '-e --exclude <pattern>', 'regexp matcher for wich tests being excluded. Default is manually'
      .parse process.argv

  findRoot: ->
    @root = if @program.root then @program.root else 'end2endTests'
    @root = do process.cwd + '/' + @root if @root.indexOf '/' isnt -1
    @root += '/'

  loadConfig: ->
    configParser = new (require './configParser')
    configPath = @root + '/' + (if @program.config then @program.config else 'config.yml')

    @config = configParser.load __dirname + '/../config.yml'
    @config = configParser.load configPath, @config

  extendConfig: ->
    @config.browser.browserName = @program.browser or @config.browser.browserName
    @config.root = @root

  createLogger: ->
    path = @config.logger.class
    if path[0] isnt '/' and path[1] isnt ':'
      fs = require 'fs'
      if fs.existsSync @root + path
        path = @root + path
      else if fs.existsSync __dirname + '/../' + path
        path = __dirname + '/../' + path

    require 'coffee-script/register' if path.match /\.coffee$/
    @logger = new (require path) @config.logger.config

  findTestFiles: ->
    @testFiles = (require 'glob').sync @root + '**/*Test.*'

    grepRegexp = @program.grep or @config.runner.grep
    @filterTests grepRegexp, 'match'

    excludeRegexp = if grepRegexp then undefined else @program.exclude or @config.runner.exclude
    @filterTests excludeRegexp

    do @handleCoffescript

  filterTests: (regexp, match = false) ->
    return false if not regexp

    regexp = new RegExp regexp
    @testFiles = @testFiles.filter (file) =>
      matched = file.replace(@root, '').match regexp
      (match and matched) or (not match and not matched)

  handleCoffescript: ->
    try
      require 'coffee-script/register' if @testFiles.some (file) -> file.match /\.coffee$/
    catch error
      @filterTests '\.coffee$'
      @logger.warn 'Coffee tests cannot be executed with coffee-script so these tests are removed from the hit list.'

  createRunner: ->
    selenium = new (require './selenium') @config, @logger
    selenium
      .start()
      .then =>
        runner = new (require './runner') @testFiles, @config, @logger
        do runner.start
