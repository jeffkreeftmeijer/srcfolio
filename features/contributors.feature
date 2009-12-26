Feature: Contributors
  In order to give contributors a nice page to show the projects they've worked on
  A user
  Should be able to view contributors' pages

	Scenario: A user views the contributor list
		Given a contributor exists with a login of "al1ce" and a name of "Alice"
		And a contributor exists with a login of "b0b" and a name of "Bob"
		When I go to the contributor list
		Then I should see "Alice"
		And I should see "Bob"
		When I follow "Alice"
		Then I should be on Alice's page

  Scenario: A user views a contributor's page
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    When I go to Alice's page
    Then I should see "Alice"
		And I should not see "We've never heard of “al1ce” before."

  Scenario: A user views a contributor's page who has contributed to a project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1"
    When I go to Alice's page
    Then I should see "project1"
    And I should see "10/100"
    And I should see "January 1 2009"
    And I should see "December 1 2009"
    And I should see "Owned by Bob"

  Scenario: A user tries to view a contributor page that doesn't exist
    Given there are no contributors
    When I go to the contributor page with a login of "z0e"
    Then I should see "We've never heard of “z0e” before."
    And I should see "We're going to ask Github if it knows this user. Please check back in a bit."
