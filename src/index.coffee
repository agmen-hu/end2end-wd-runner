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
    @root = do process.cwd + '/' + @root if @root[0] isnt '/' and @root[1] isnt ':'
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
    @logger = new (require './loggerFactory')()
      .createFrom @config

  createRunner: ->
    new (require './selenium') @config, @logger
      .start()
      .then =>
        new (require './testSuiteRunner') @config, @logger
          .start()
      .fail (error) =>
        @logger.error "Selenium exited with code: #{error}"
