Feature: Contributors
  In order to give contributors a nice page to show the projects they've worked on
  A user
  Should be able to view contributors' pages

  Scenario: A user views a contributor's page
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    When I go to the contributor page with a login of "al1ce"
    Then I should see "Alice"

  Scenario: A user views a contributor's page who has contributed to some projects
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1" which is owned by Bob
    And Alice has contributed to a project named "project2" which is owned by Charlie
    When I go to the contributor page with a login of "al1ce"
    Then I should see "project1"
    And I should see "project2"
    And I should see "Bob"
    And I should see "Charlie"

  Scenario: A user tries to view a contributor page that doesn't exist
    Given there are no contributors
    When I go to the contributor page with a login of "al1ce"
    Then I should see "We've never heard of &ldquo;al1ce&rdquo; before."
    And I should see "We're going to ask Github if it knows this user. Please check back in a bit."
