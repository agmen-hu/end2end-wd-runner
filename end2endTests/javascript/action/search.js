module.exports = Search = require('../../../main').createNewAction();

// all method which is ending with Action added to the wd
Search.prototype.searchAction = function(context, where)
{
  $this = this;
  return context
    .get(this._config.urls[where] + this._config.search.forWhat)
    .then(function(){ $this.logger.debug('url loaded', {url: $this._config.urls[where], what: $this._config.search.forWhat})})
    .pageHasWikipediaShortcut(where);
}

Search.prototype.pageHasWikipediaShortcutAction = function(context, where)
{
  if (where != 'google') {
    return false;
  }

  $this = this;
  return context
      .hasElementById('rcnt')
      .then(function(exists){
        return exists ? $this._shourtCutFound() : false;
      });
}

Search.prototype._shourtCutFound = function()
{
  this.logger.info('Page has a wikipedia shortcut');
}
