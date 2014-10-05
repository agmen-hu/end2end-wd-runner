module.exports = class ContextBuilder
  constructor: ->
    @_freshContext = false

  init: (config, logger)->
    @_config = config
    @logger = logger

  setDirty: ->
    @_freshContext = false

  build: ->
    do @getData if @_freshContext
    do @_browser.quit if @_browser

    @_wd = require 'wd'
    chai = require 'chai'
    chaiAsPromised = require 'chai-as-promised'

    chai.use chaiAsPromised
    do chai.should
    chaiAsPromised.transferPromiseness = @_wd.transferPromiseness

    @_browser = @_wd.promiseChainRemote if @_config.wdRemote then @_config.wdRemote else undefined
    @_context = @_browser.init @_config.browser
    @_freshContext = true

    do @_addCustomAction
    do @getData

  getData: ->
    _browser: @_browser, _context: @_context, _wd: @_wd

  _addCustomAction: ->
    for action in (require 'glob').sync __dirname + '/action/*'
      new (require action) @_wd, @_browser, @_config, @logger
