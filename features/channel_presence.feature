@javascript
Feature: Client on a presence channel

  Background:
    Given I am connected

  Scenario: Client subscribes to a presence channel
    When I subscribe to the "presence-game-1" channel with presence events
    Then I should see 1 client
    When Bob is connected
    Then I should see 1 client
    When Bob is subscribed to the "presence-game-1" channel
    Then I should see 2 clients

  Scenario: Client unsubscribes from a presence channel, with other clients
    Given Bob is connected
    And Bob is subscribed to the "presence-game-1" channel
    When I subscribe to the "presence-game-1" channel with presence events
    Then I should see 2 clients
    When Bob unsubscribes from the "presence-game-1" channel
    Then I should see 1 client

  Scenario: Subscribing client should receive User info
    Given Bob is connected
    And Bob is subscribed to the "presence-game-1" channel
    When I subscribe to the "presence-game-1" channel with presence events
    Then I should see 2 clients with the name "Alan Turing"
