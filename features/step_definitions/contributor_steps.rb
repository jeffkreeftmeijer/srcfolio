Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name) unless Contributor.find_by_login(login)
end

Given /^there are no contributors$/ do
  Contributor.delete_all
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {:project => Project.make(:name => project).id, :started_at => 'January 1 2009', :stopped_at => 'December 1 2009', :commits => 10}
  contributor.save
end
