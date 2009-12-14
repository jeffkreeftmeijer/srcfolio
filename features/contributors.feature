Feature: Contributors
  In order to give contributors a nice page to show the projects they've worked on
  A user
  Should be able to view contributors' pages
  
  Scenario: A user views a contributor's page
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    When I go to Alice's page
    Then I should see "Alice"
    
    
  Scenario: A user views a contributor's page who has contributed to some projects
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1" which is owned by Bob
    And Alice has contributed to a project named "project2" which is owned by Charlie
    When I go to Alice's page
    Then I should see "project1"
    And I should see "project2"
    And I should see "Bob"
    And I should see "Charlie"
