module.exports = class LoggerFactory
  constructor: ->
    @fs = require 'fs'

  createFrom: (config)->
    path = config.logger.class
    if path[0] isnt '/' and path[1] isnt ':'
      if @fs.existsSync config.root + path
        path = config.root + path
      else if @fs.existsSync __dirname + '/../' + path
        path = __dirname + '/../' + path

    require 'coffee-script/register' if path.match /\.coffee$/

    new (require path) config.logger.config
