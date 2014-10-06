fs = require 'fs'
path = require 'path'
yml = require 'js-yaml'
extend = require 'extend'

module.exports = class ConfigParser
  merge: (config1, config2) ->
    extend true, {}, config1, config2

  load: (path, config = {}) ->
    newConfig = @_parse path, []
    @merge config, newConfig

  _parse: (path, included) ->
    return {} if @_isRecursiveInclude path, included
    @_processIncludeDirective path, @_loadYamlFile(path), included

  _isRecursiveInclude: (path, included) ->
    return true if included.indexOf(path) isnt -1
    return false

  _loadYamlFile: (path) ->
    throw new Error "Config not found: #{path}" if not fs.existsSync path
    return yml.safeLoad fs.readFileSync path, 'utf8'

  _processIncludeDirective: (path, config, included) ->
    return config if not config.include

    if not Array.isArray config.include
      config.include = [ config.include ]

    for includePath in config.include
      includePath = @_buildPathToInclude path, includePath
      config = @merge config, @_parse(includePath, included)

    delete config.include

    return config

  _buildPathToInclude: (fromResource, resourceToInclude) ->
    path.dirname(fromResource) + '/' + resourceToInclude
