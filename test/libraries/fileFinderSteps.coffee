sinon = require 'sinon'
FileFinder = require '../../src/fileFinder'

module.exports = (require '../library')()
  .given 'these test files $FILELIST', (fileList) ->
    @context.glob = do sinon.stub
    @context.glob.returns JSON.parse fileList

  .given 'a new file finder', ->
    @context.fileFinder = new FileFinder sync: @context.glob
    @context.fileFinder.init @context.config, warn: do sinon.spy

  .when 'grep $name', (name) ->
    @context.config.runner.grep = name

  .when 'exclude $name', (name) ->
    @context.config.runner.exclude = name

  .then 'test files are $FILELIST', (expectedTestFiles) ->
    testFiles = do @context.fileFinder.findTestFiles
    testFiles.should.be.eql JSON.parse expectedTestFiles
