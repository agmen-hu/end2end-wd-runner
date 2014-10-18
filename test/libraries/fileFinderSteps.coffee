chai = require 'chai'
sinon = require 'sinon'
Yadda = require 'yadda'
FileFinder = require '../../src/fileFinder'
Dictionary = Yadda.Dictionary
English = Yadda.localisation.English
do chai.should

module.exports = do ->
  glob = undefined
  config = undefined
  fileFinder = undefined

  dictionary = new Dictionary()
    .define 'OBJECT', /(\{.+\})/
    .define 'FILELIST', /(\[.+\])/

  library = English.library(dictionary)
    .given 'config $OBJECT', (object) ->
      config = JSON.parse object

    .given 'these test files $FILELIST', (fileList) ->
      glob = do sinon.stub
      glob.returns JSON.parse fileList

    .given 'a new file finder', ->
      fileFinder = new FileFinder sync: glob
      fileFinder.init config, warn: do sinon.spy

    .when 'grep $name', (name) ->
      config.runner.grep = name

    .when 'exclude $name', (name) ->
      config.runner.exclude = name

    .then 'test files are $FILELIST', (expectedTestFiles) ->
      testFiles = do fileFinder.findTestFiles
      testFiles.should.be.eql JSON.parse expectedTestFiles
