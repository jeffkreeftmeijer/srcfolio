Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name)
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)" which is owned by ([^\"]*)$/ do |contributor, project, owner|
  pending
end

Given /^([^\"]*) owns a project named "([^\"]*)"$/ do |owner, project|
  pending
end
