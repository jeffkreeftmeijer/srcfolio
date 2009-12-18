Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name)
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)" which is owned by ([^\"]*)$/ do |contributor, project, owner|
  contributor = Contributor.find_by_name(contributor)
  owner = Contributor.make(:name => owner)
  project = Project.make(:name => project)
  project.owner = owner
  contributor.contributions << project
end

Given /^there are no contributors$/ do
  Contributor.delete_all
end
