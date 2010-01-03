Given /^a contributor exists with a login of "([^\"]*)"$/ do |login|
  Contributor.make(:login => login, :name => nil) unless Contributor.find_by_login(login)
end

Given /^a contributor exists with a name of "([^\"]*)"$/ do |name|
  Contributor.make(:login => '', :name => name) unless Contributor.find_by_name(name)
end

Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)"$/ do |login, name|
  Contributor.make(:login => login, :name => name) unless Contributor.find_by_login(login)
end

Given /^a contributor exists with a login of "([^\"]*)" and a name of "([^\"]*)", who is invisible$/ do |login, name|
  Contributor.make(:login => login, :name => name, :visible => false) unless Contributor.find_by_login(login)
end

Given /^there are no contributors$/ do
  Contributor.delete_all
end

Given /^([^\"]*) has no contributions$/ do |name|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.save
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor, :commits => 46).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :visible => true
  }
  contributor.save
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)" in "([^\"]*)"$/ do |name, project, month|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => Contributor.make).id,
    :started_at => "1 #{month}",
    :stopped_at => "1 #{month}",
    :commits => 12,
    :visible => true
  }
  contributor.save
end


Given /^([^\"]*) has contributed to a project named "([^\"]*)" which is owned by ([^\"]*)$/ do |name, project, owner|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => Contributor.make(:name => owner)).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :visible => true
  }
  contributor.save
end

Given /^^([^\"]*) has contributed to a project named "([^\"]*)" which has a source code link$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => Contributor.make(:name => contributor), :links => [Link.new(:name => 'Source Code', :url => 'http://github.com/some/repo')]).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :visible => true
  }
  contributor.save
end


Given /^([^\"]*) owns a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor).id,
    :owner => true,
    :visible => true
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project).id,
    :member => true,
    :visible => true
  }
  contributor.save
end

Given /^([^\"]*) owns a project named "([^\"]*)" and has contributed to that project$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  project = Project.make(:name => project, :owner => contributor)
  contributor.contributions << {
    :project => project.id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :owner => true,
    :visible => true
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)" and has contributed to that project$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  project = Project.make(:name => project)
  contributor.contributions << {
    :project => project.id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :member => true,
    :visible => true
  }
  contributor.save
end

Given /^([^\"]*) has contributed to a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project).id,
    :started_at => 'January 1 2009',
    :stopped_at => 'December 1 2009',
    :commits => 12,
    :visible => false
  }
  contributor.save
end

Given /^([^\"]*) owns a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :owner => contributor).id,
    :owner => true,
    :visible => false
  }
  contributor.save
end

Given /^([^\"]*) is in the team of a project named "([^\"]*)", which is invisible$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project).id,
    :member => true,
    :visible => false
  }
  contributor.save
end

Given /^([^\"]*) owns a fork of "([^\"]*)"$/ do |name, project|
  contributor = Contributor.find_by_name(name)
  contributor.contributions = []
  contributor.contributions << {
    :project => Project.make(:name => project, :namespace => contributor.login, :fork => true, :owner => contributor).id,
    :owner => true,
    :visible => true
  }
  contributor.save
end

Then /^I should see ([^\"]*)'s gravatar$/ do |name|
  contributor = Contributor.find_by_name(name)
  response.body.should include(contributor.gravatar_url[0,67])
end

Then /^I should not see the gravatar of the user with a login of "([^\"]*)"$/ do |login|
  contributor = Contributor.find_by_login(login)
  response.body.should_not include(contributor.gravatar_url[0,67])
end


Then /^I should not see ([^\"]*)'s gravatar$/ do |name|
  contributor = Contributor.find_by_name(name)
  response.body.should_not include(contributor.gravatar_url[0,67])
end


Then /^I should see an? (team|owner|fork) ribbon$/ do |type|
  response.body.should include "src=\"/images/ribbon_#{type}.gif"
end

Then /^I should see "([^\"]*)" which links to "([^\"]*)"$/ do |text, url|
  response.should contain(text)
  response.body.should include(url)
end


