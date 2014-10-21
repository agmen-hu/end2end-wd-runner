Fs = require 'fake-fs'
yml = require 'js-yaml'
ConfigParser = require '../../src/configParser'

module.exports = (require '../library')()
  .given 'a new config parser', ->
    @context.fs = new Fs
    @context.configParser = new ConfigParser @context.fs

  .given 'a config file $PATH with content $OBJECT', (path, content) ->
    @context.fs.file path, yml.safeDump JSON.parse content

  .when 'merge $OBJECT to $OBJECT', (source, target) ->
    source = JSON.parse source
    target = JSON.parse target
    @context.config = @context.configParser.merge source, target

  .when '$PATH is loaded', (path) ->
    @context.config = @context.configParser.load path, if @context.config then @context.config else undefined

  .then 'config is $OBJECT', (obj) ->
    @context.config.should.be.eql JSON.parse obj
