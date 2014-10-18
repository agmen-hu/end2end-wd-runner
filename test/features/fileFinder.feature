Feature: Test file finding

Background:

  Given config {"root": "end2endTests", "runner": { "grep": "", "exlude":""}}
  Given these test files ["end2endTests/fooTest.js", "end2endTests/fooTest.coffee", "end2endTests/barTest.coffee"]

Scenario: Should file all files
  Given a new file finder
  Then test files are ["end2endTests/fooTest.js", "end2endTests/fooTest.coffee", "end2endTests/barTest.coffee"]

Scenario: Should be able to run only the requested tests
  Given a new file finder
  When grep bar
  Then test files are ["end2endTests/barTest.coffee"]

Scenario: Should be able to exlude tests
  Given a new file finder
  When exclude .coffee
  Then test files are ["end2endTests/fooTest.js"]

Scenario: Should not exclude when already grepped for tests
  Given a new file finder
  When exclude bar
  When grep bar
  Then test files are ["end2endTests/barTest.coffee"]
