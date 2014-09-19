module.exports = Search = require('../../../main').createNewAction();

// all method which is ending with Action added to the wd
Search.prototype.searchAction = function(context, where)
{
  return context
    .get(this._config.urls[where] + this._config.search.forWhat)
    .pageHasWikipediaShortcut(where);
}

Search.prototype.pageHasWikipediaShortcutAction = function(context, where)
{
  // must return a promise hence the shortcut for the browser.noop
  if (where != 'google') {
    return this._nothing();
  }

  $this = this;
  return context
      .hasElementById('rcnt')
      .then(function(exists){
        return exists ? $this._shourtCutFound() : $this._nothing();
      });
}

Search.prototype._shourtCutFound = function()
{
  console.log('Page has a wikipedia shortcut');
  return this._nothing();
}
