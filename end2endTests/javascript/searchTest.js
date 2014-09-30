module.exports = SearchTest = require('../../main').createNewTestCase();

SearchTest.prototype._actions = [
  'javascript/action/search'
]

// must return a promise
SearchTest.prototype.test = function()
{
  return this._browser
    .search('google')
    .search('bing');
}

// must return a promise
SearchTest.prototype.tearDown = function()
{
  this.logger.info('search test finished');
  return this._browser.chain();
}
