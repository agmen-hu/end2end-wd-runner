var wd = require('wd');

function createChild(_super) {
  var __hasProp, __extends;
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  var Child;
  return (function(_super) {
    __extends(Child, _super);

    function Child() {
      return Child.__super__.constructor.apply(this, arguments);
    }

    return Child;
  })(_super);
}

var Action = require('./lib/action');
var TestCase = require('./lib/testCase');

module.exports = {
  Action: Action,
  TestCase: TestCase,
  wd: wd,
  Q: wd.Q,
  Asserter: wd.Asserter,
  asserters: wd.asserters,

  // for easer vanilla js inheritance
  createChild: createChild,
  createNewAction: function() { return createChild(Action) },
  createNewTestCase: function() { return createChild(TestCase) }
}
