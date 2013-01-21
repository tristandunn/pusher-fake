@javascript
Feature: Requesting channel information

  Background:
    Given I am connected

  Scenario: Requesting all channels
    When I request "/channels"
    Then I should receive the following JSON:
      """
        { "channels" : {} }
      """
    When I subscribe to the "chat-message" channel
    And I request "/channels"
    Then I should receive the following JSON:
      """
        { "channels" : {
            "chat-message" : {}
          }
        }
      """
    When I subscribe to the "presence-game-1" channel with presence events
    And I request "/channels"
    Then I should receive the following JSON:
      """
        { "channels" : {
            "chat-message"    : {},
            "presence-game-1" : {}
          }
        }
      """

  Scenario: Requesting all channels, with a filter
    Given I subscribe to the "chat-message" channel
    And I subscribe to the "presence-game-1" channel with presence events
    When I request "/channels" with the following options:
      | filter_by_prefix |
      | chat             |
    Then I should receive the following JSON:
      """
        { "channels" : {
            "chat-message" : {}
          }
        }
      """

  Scenario: Requesting all channels, with a valid filter and info attributes
    Given I subscribe to the "chat-message" channel
    And I subscribe to the "presence-game-1" channel with presence events
    When I request "/channels" with the following options:
      | filter_by_prefix | info       |
      | presence-        | user_count |
    Then I should receive the following JSON:
      """
        { "channels" : {
            "presence-game-1" : {
              "user_count" : 1
            }
          }
        }
      """

  Scenario: Requesting all channels, with an invalid filter and info attributes
    Given I subscribe to the "chat-message" channel
    And I subscribe to the "presence-game-1" channel with presence events
    When I request "/channels" with the following options:
      | filter_by_prefix | info       |
      | chat-            | user_count |
    Then I should receive the following error:
      """
        user_count may only be requested for presence channels - please supply filter_by_prefix begining with presence-
      """
