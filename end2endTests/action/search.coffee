module.exports = class Search extends require('../../main').Action
  searchAction: (context, where) ->
    context
      .get @_config.urls[where] + @_config.search.forWhat
      .pageHasWikipediaShortcut where

  pageHasWikipediaShortcutAction: (context, where) ->
    # must return a promise hence the shortcut for browser.noop
    return do @_nothing if where isnt 'google'

    @_browser
      .hasElementById 'rcnt'
      .then (exists) => if exists then do @_shourtCutFound else do @_nothing

  _shourtCutFound: ->
    console.log 'Page has a wikipedia shortcut'
    do @_nothing
