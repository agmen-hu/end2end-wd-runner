module.exports = class ContextBuilder
  constructor: (@_config)->
    @_isDirty = true
    @_forceToCreate = true
    @_prevConfig = @_config

    @_wd = require 'wd'
    chai = require 'chai'
    chaiAsPromised = require 'chai-as-promised'

    chai.use chaiAsPromised
    do chai.should
    chaiAsPromised.transferPromiseness = @_wd.transferPromiseness

  init: (config, logger)->
    @_config = config
    @logger = logger
    do @_checkConfigIsChanged

  _checkConfigIsChanged: ->
    try
      @_config.browser.should.be.eql @_prevConfig.browser
      if not @_config.wdRemote
        throw new Error 'Wd config changed' if @_prevConfig.wdRemote
      else
        @_config.wdRemote.should.be.eql @_prevConfig.wdRemote
    catch err
      @_isDirty = true
      @_forceToCreate = true

    @_prevConfig = @_config

  markAsDirty: ->
    @_isDirty = true

  getData: ->
    if @_forceToCreate
      return do @build

    _browser: @_browser, _context: @_context, _wd: @_wd

  build: ->
    return do @getData if not @_forceToCreate and not @_isDirty
    do @_browser.quit if @_browser

    @_browser = @_wd.promiseChainRemote if @_config.wdRemote then @_config.wdRemote else undefined
    @_context = @_browser.init @_config.browser
    @_isDirty = false
    @_forceToCreate = false

    do @_addCustomAction
    do @getData

  _addCustomAction: ->
    for action in (require 'glob').sync __dirname + '/action/*'
      new (require action) @_wd, @_browser, @_config, @logger
