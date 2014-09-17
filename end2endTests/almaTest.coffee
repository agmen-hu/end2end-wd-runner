module.exports = class SearchTest extends require('../main').TestCase
  _actions: [
    'action/search'
  ]

  _hits: {}

  test: ->
    @_context
      .noop()
      .search 'google'
      .search 'bing'
