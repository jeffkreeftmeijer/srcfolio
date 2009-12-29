Feature: Contributors
  In order to give contributors a nice page to show the projects they've worked on
  A user
  Should be able to view contributors' pages

	Scenario: A user views the contributor list
		Given a contributor exists with a login of "al1ce" and a name of "Alice"
		And a contributor exists with a login of "b0b" and a name of "Bob"
		And a contributor exists with a login of "ch4rlie"
		And a contributor exists with a name of "Dave"
		When I go to the contributor list
		Then I should see "Alice"
		And I should see "Bob"
		And I should see "ch4rlie"
		And I should not see "/contributors/"
		When I follow "Alice"
		Then I should be on Alice's page

  Scenario: A user views a contributor's page
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    When I go to Alice's page
    Then I should see "Alice"
    And I should see Alice's gravatar
		And I should not see "We've never heard of “al1ce” before."

  Scenario: A user views a contributor's page that has no contributions
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has no contributions
    When I go to Alice's page
    Then I should see "We couldn't find any projects Alice has contributed to."

  Scenario: A user views a contributor's page who has contributed to a project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1"
    When I go to Alice's page
    Then I should see "project1"
    And I should see "A really cool project"
    And I should see "12/46 (26.09%)"
    And I should see "January 2009"
    And I should see "December 2009"
    And I should not see "Owned by"
    
  Scenario: A user views a contributor's page who has contributed to a project in December 2009
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1" in "December 2009"
    When I go to Alice's page
    Then I should see "in"
    And I should see "December 2009" once
    And I should not see "from"
    And I should not see "to"

  Scenario: A user views a contributor's page who has contributed to a project owned by somebody else
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1" which is owned by Bob
    When I go to Alice's page
    Then I should see "Owned by"
    And I should see "Bob"
    When I follow "Bob"
    Then I should be on Bob's page
  
  Scenario: A user views a contributor's page who owns a project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice owns a project named "project1"
    When I go to Alice's page
    Then I should see "project1"
    And I should see an owner ribbon
    And I should not see "We couldn't find any projects Alice has contributed to." 
    
  Scenario: A user views a contributor's page who is in a project team
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice is in the team of a project named "project1"
    When I go to Alice's page
    Then I should see "project1"
    And I should see a team ribbon
    And I should not see "We couldn't find any projects Alice has contributed to."
  
  Scenario: A user views a contributor's page who has contributed to an invisible project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice has contributed to a project named "project1", which is invisible
    When I go to Alice's page
    Then I should not see "project1"
    And I should see "We couldn't find any projects Alice has contributed to."
    
  Scenario: A user views a contributor's page who owns an invisible project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice is in the team of a project named "project1", which is invisible
    When I go to Alice's page
    Then I should not see "project1"
    And I should see "We couldn't find any projects Alice has contributed to."
  
  Scenario: A user views a contributor's page who owns a project and contributed to that project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice owns a project named "project1" and has contributed to that project
    When I go to Alice's page
    Then I should see "project1" once
    And I should not see "We couldn't find any projects Alice has contributed to."
    
  Scenario: A user views a contributor's page who is in the team of an invisible project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice owns a project named "project1", which is invisible
    When I go to Alice's page
    Then I should not see "project1"
    And I should see "We couldn't find any projects Alice has contributed to."
  
  Scenario: A user views a contributor's page who is in a project team and contributed to that project
    Given a contributor exists with a login of "al1ce" and a name of "Alice"
    And Alice is in the team of a project named "project1" and has contributed to that project
    When I go to Alice's page
    Then I should see "project1" once
    And I should not see "We couldn't find any projects Alice has contributed to." 
  
  Scenario: A user tries to view a contributor page that doesn't exist
    Given there are no contributors
    When I go to the contributor page with a login of "z0e"
    Then I should see "We've never heard of “z0e” before."
    And I should see "We're going to ask Github if it knows this user. Please check back in a bit."
