@javascript
Feature: Requesting user information

  Scenario: Requesting users for a channel
    Given I am connected
    And Bob is connected
    When I request "/channels/public-1/users"
    Then I should receive JSON for 0 users
    When I subscribe to the "public-1" channel
    And I request "/channels/public-1/users"
    Then I should receive JSON for 1 user
    When Bob is subscribed to the "public-1" channel
    And I request "/channels/public-1/users"
    Then I should receive JSON for 2 users
