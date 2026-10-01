Feature: Library book lending
  Patrons borrow books; when no copy is available they join a hold queue, and returns respect
  that queue.

  Scenario: Borrow an available book
    Given the library has 1 copy of "Dune"
    When Ada borrows "Dune"
    Then Ada has "Dune"
    And "Dune" is not available

  Scenario: Join the hold queue when no copy is available
    Given the library has 1 copy of "Dune"
    And Ada has borrowed "Dune"
    When Grace tries to borrow "Dune"
    Then Grace is placed on the hold queue at position 1

  Scenario: A returned book is reserved for the next patron in the hold queue
    Given the library has 1 copy of "Dune"
    And Ada has borrowed "Dune"
    And Grace is on the hold queue for "Dune"
    When Ada returns "Dune"
    Then "Dune" is reserved for Grace
    And "Dune" is not available

  Scenario: A returned book with no holds becomes available
    Given the library has 1 copy of "Dune"
    And Ada has borrowed "Dune"
    When Ada returns "Dune"
    Then "Dune" is available
