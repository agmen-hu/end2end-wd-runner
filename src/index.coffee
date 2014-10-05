module.exports = class Index
  program: require 'commander'

  start: ->
    do @processsArgv
    do @findRoot
    do @loadConfig
    do @extendConfig
    do @createLogger
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
    @config.browser.browserName or= @program.browser
    @config.runner.exclude or= @program.exclude
    @config.runner.grep or= @program.grep
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

  createRunner: ->
    selenium = new (require './selenium') @config, @logger
    selenium
      .start()
      .then =>
        fileFinder = new (require './fileFinder')
        fileFinder.setLogger @logger
        fileFinder.setConfig @config
        runner = new (require './testCaseRunner') do fileFinder.findTestFiles, @config, @logger
        do runner.start
      .fail (error) =>
        @logger.error "Selenium exited with code: #{error}"
