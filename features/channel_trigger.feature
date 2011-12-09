@javascript
Feature: Client triggering an event on a channel

  Background:
    Given I am connected
    And Bob is connected

  Scenario: Client triggers an event on a subscribed channel
    Given I am subscribed to the "chat-message" channel
    And Bob is subscribed to the "chat-message" channel
    When I trigger the "body" event on the "chat-message" channel
    Then I should receive a "body" event on the "chat-message" channel
    And Bob should receive a "body" event on the "chat-message" channel

  Scenario: Client triggers an event on an unsubscribed channel
    Given Bob is subscribed to the "chat-message" channel
    When I manually trigger the "body" event on the "chat-message" channel
    Then I should not receive a "body" event on the "chat-message" channel
    And Bob should not receive a "body" event on the "chat-message" channel
