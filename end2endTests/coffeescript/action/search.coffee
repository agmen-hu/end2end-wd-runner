module.exports = class Search extends require('../../../main').Action
  # all method which is ending with Action added to the wd
  searchAction: (context, where) ->
    context
      .get @_config.urls[where] + @_config.search.forWhat
      .then => @logger.debug 'url loaded', url: @_config.urls[where], what: @_config.search.forWhat
      .pageHasWikipediaShortcut where

  pageHasWikipediaShortcutAction: (context, where) ->
    # just a shortcut for the browser.noop
    return do @_nothing if where isnt 'google'

    context
      .hasElementById 'rcnt'
      .then (exists) => if exists then do @_shourtCutFound else do @_nothing

  _shourtCutFound: ->
    @logger.info 'Page has a wikipedia shortcut'
