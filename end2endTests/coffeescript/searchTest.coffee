module.exports = class SearchTest extends require('../../main').TestCase
  _actions: [
    'coffeescript/action/search'
  ]

  # must return a promise
  test: ->
    @_browser
      .search 'google'
      .search 'bing'

  # must return a promise
  tearDown: ->
    @logger.info 'search test finished'
    do @_browser.chain
