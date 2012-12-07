@javascript
Feature: Triggering channel webhooks

  Background:
    Given I am connected
    And Bob is connected

  Scenario: Occupying and vacating a channel
    When I subscribe to the "game-1" channel
    Then the server should have received the following event:
      | name    | channel_occupied |
      | channel | game-1           |
    When Bob is subscribed to the "game-1" channel
    Then the server should have received no events
    When Bob unsubscribes from the "game-1" channel
    Then the server should have received no events
    When I unsubscribe from the "game-1" channel
    Then the server should have received the following event:
      | name    | channel_vacated |
      | channel | game-1          |

  Scenario: Subscribing and unsubscribing from a presence channel
    When I subscribe to the "presence-chat-1" channel
    Then the server should have received the following user event:
      | name    | member_added    |
      | channel | presence-chat-1 |
    When Bob is subscribed to the "presence-chat-1" channel
    Then the server should have received the following user event:
      | user    | Bob             |
      | name    | member_added    |
      | channel | presence-chat-1 |
    When Bob unsubscribes from the "presence-chat-1" channel
    Then the server should have received the following user event:
      | user    | Bob             |
      | name    | member_removed  |
      | channel | presence-chat-1 |
    When I unsubscribe from the "presence-chat-1" channel
    Then the server should have received the following user event:
      | name    | member_removed  |
      | channel | presence-chat-1 |
