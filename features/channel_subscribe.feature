@javascript
Feature: Client subscribing to a channel

  Background:
    Given I am on the homepage
    Then I should be connected

  Scenario: Client subscribes to a channel
    When I subscribe to the "chat-message" channel
    Then I should be subscribed to the "chat-message" channel

  Scenario: Client subscribes to multiple channels
    When I subscribe to the "chat-enter" channel
    And I subscribe to the "chat-exit" channel
    Then I should be subscribed to the "chat-enter" channel
    And I should be subscribed to the "chat-exit" channel
