module.exports = SearchTest = require('../../main').createNewTestCase();

SearchTest.prototype._actions = [
  'javascript/action/search'
]

SearchTest.prototype.test = function()
{
  return this._context
    // the first context does not have the custom actions
    .noop()
    .search('google')
    .search('bing');
}

SearchTest.prototype.tearDown = function()
{
  console.log('search test finished');
  // must return a promise
  // the context which is returned by the test method
  return this._context.noop();
}
