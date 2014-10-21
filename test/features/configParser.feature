Feature: Configuration parsing

Scenario: Should merge two config object
  Given a new config parser
  When merge {"foo": { "bar": true, "bar2": false}} to {"foo": { "bar": false, "bar3": false }, "foo2": false}
  Then config is {"foo": { "bar": false, "bar3": false, "bar2":false }, "foo2": false}

Scenario: Should be able to load a config file from the file system
  Given a new config parser
  And a config file ./config.yml with content {"foo": "bar"}
  When ./config.yml is loaded
  Then config is {"foo": "bar"}

Scenario: Should be able to merge two config file
  Given a new config parser
  And a config file ./config.yml with content {"foo": "bar"}
  And a config file ./config2.yml with content {"bar": "foo"}
  When ./config.yml is loaded
  And ./config2.yml is loaded
  Then config is {"foo": "bar", "bar": "foo"}

Scenario: A config file include another config file case
  Given a new config parser
  And a config file ./config.yml with content {"foo": "bar", "bar2": "foo2"}
  And a config file ./folder/config2.yml with content {"include":["../config.yml"], "bar": "foo", "foo": "new bar"}
  When ./folder/config2.yml is loaded
  Then config is {"foo": "new bar", "bar": "foo", "bar2": "foo2"}
