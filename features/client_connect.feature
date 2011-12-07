@javascript
Feature: Client connecting to the server

  Scenario: Client connects to the server
    Given I am on the homepage
    Then I should be connected

  @disable-server
  Scenario: Client unsuccessfully connects to the server
    Given I am on the homepage
    Then I should not be connected
