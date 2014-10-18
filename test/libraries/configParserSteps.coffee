chai = require 'chai'
Yadda = require 'yadda'
yml = require 'js-yaml'
ConfigParser = require '../../src/configParser'
Dictionary = Yadda.Dictionary
English = Yadda.localisation.English
Fs = require 'fake-fs'
do chai.should

module.exports = do ->
  fs = undefined
  config = undefined
  configParser = undefined

  dictionary = new Dictionary()
    .define 'OBJECT', /(\{.+\})/

  library = English.library(dictionary)
    .given 'a new config parser', ->
      fs = new Fs
      config = undefined
      configParser = new ConfigParser fs

    .given 'a config file $PATH with content $OBJECT', (path, content) ->
      fs.file path, yml.safeDump JSON.parse content

    .when 'merge $OBJECT to $OBJECT', (source, target) ->
      source = JSON.parse source
      target = JSON.parse target
      config = configParser.merge source, target

    .when '$PATH is loaded', (path) ->
      config = configParser.load path, if config then config else undefined

    .then 'config is $OBJECT', (obj) ->
      config.should.be.eql JSON.parse obj
