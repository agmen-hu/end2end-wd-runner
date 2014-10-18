Feature: Timer class

Scenario: Should be able to tell the passed time since started
  Given a new Timer
  When start called since 250ms
  Then time is 250ms
  When time is passed by 400ms
  Then time is 400ms
  Then the overall time since the timer started is 650ms
