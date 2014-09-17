module.exports = class SearchTest extends require('../main').TestCase
  _actions: [
    'action/search'
  ]

  test: ->
    @_context
      # the first context does not have the custom actions
      .noop()
      .search 'google'
      .search 'bing'
